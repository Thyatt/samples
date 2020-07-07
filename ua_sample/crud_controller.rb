class CrudController < ApplicationController
  include Feed
  include Gibbon

  def new(klass)
    if (SiteConfig.first.site_status == 'prelaunch' && (!params[:devBypass].present? || (params[:devBypass] != "true" && params[:devBypass] != true))) || SiteConfig.first.site_status == 'complete'
      respond_site_status(klass)
      return false
    end

    if klass.classify.constantize.valid_attributes(params)
      record = klass.classify.constantize.new
      record.write(params)
      if record.save
        if (klass == 'coach')
          puts "-- Registering Coach: #{params.reject { |key| key.include?('password') }.inspect}"

          # If this includes a token, find the team it represents, make the Coach an "uploader" type, and attach it to the team
          if !params[:token].blank?
            record.is_uploader = true
            record.team = Team.find_by_token(params[:token].upcase)
            record.save
            record.send_confirmation_uploader
            record.teammate_trophy

          else
            # If this is a new Coach (for which we're using the Coach class for UA Hockey), create a Team model and associate it with the new Coach
            newTeam = Team.create!({
              :name => params[:teamname],
              :arena => params[:arenaname],
              :program => params[:program],
              :postalcode => params[:postalcode],
              :clublevel => params[:clublevel]
            })

            record.team = newTeam
            record.save
            record.send_confirmation

            newTeam.check_for_avatar
            newTeam.vets_trophy
          end

          # Add this Coach to the appropriate Mailchimp list based on which program they've signed up for
          case params[:lang]
          when 'ce'
            mailchimpListId = AppEnv['MAILCHIMP_LIST_CHC_EN']
          when 'cf'
            mailchimpListId = AppEnv['MAILCHIMP_LIST_CHC_FR']
          when 'to'
            mailchimpListId = AppEnv['MAILCHIMP_LIST_MLSE']
          else
            mailchimpListId = AppEnv['MAILCHIMP_LIST_OILERS']
          end

          begin
            gibbon = Gibbon::Request.new(api_key: AppEnv['MAILCHIMP_API_KEY'])

            if params[:token].blank?
              merge_vars = { 'COACHTYPE' => 'Head coach', 'FNAME' => params[:first_name], 'LNAME' => params[:last_name] }
            else
              merge_vars = { 'COACHTYPE' => 'Team helper' }
            end

            gibbon.lists(mailchimpListId).members.create(body: { email_address: params[:email], status: 'subscribed', merge_fields: merge_vars })
          rescue => e
            puts "GIBBON (MANDRILL GEM) ERROR! Can't add user #{params[:email]} to list #{mailchimpListId}. Error: #{e}"
          end

          session = Session.create!(coach_id: record.id)
          respond_success_with_data(klass, {
            id: record.id, 
            team_token: record.team.token,
            slug: record.team.slug,
            lang: record.lang, 
            session_token: session.token, 
            session_expiration: session.expiration, 
            session_renewal_token: session.renewal_token,
            team_token: record.team.token,
            team_program: record.team.program,
            team_name: record.team.name,
            team_logo: record.team.build_logo,
            chapters_completed: record.team.frame_level,
            vote_date: Date.today #TODO FIX
          })
        else
          respond_success_with_data(klass, record.data)
        end

        if(klass = 'post')
          respond_success_with_data(klass, record.data)
        end
      else
        respond_failed_to_commit(klass, record)
      end
    else
      respond_invalid_parameters
    end
  end

  def edit(klass)
    if (SiteConfig.first.site_status == 'prelaunch' && (!params[:devBypass].present? || (params[:devBypass] != "true" && params[:devBypass] != true))) || SiteConfig.first.site_status == 'complete'
      respond_site_status(klass)
      return false
    end
    record = klass.classify.constantize.find(params[:id])
    if record
      new_params = format_and_validate_params(params)
      if new_params
        record.update(new_params)
        if record.save
          respond_success_with_data(klass, record.data)
        else
          respond_failed_to_commit(klass, record)
        end
      else
        respond_invalid_parameters
      end

    else
      respond_no_record_found_for_id(klass)
    end
  end

  def sharing(klass)
    if (params[:id])
      record = klass.classify.constantize.find_by_id(params[:id])
      _record = record.data(params[:locale])
      respond_success_with_data(klass, _record)
    end
  end

  def show(klass)
    if (params[:id])
      record = klass.classify.constantize.find_by_id(params[:id])
    elsif (params[:token])
      record = klass.classify.constantize.find_by_token(params[:token])
    elsif (params[:slug])
      record = klass.classify.constantize.find_by_slug(params[:slug])
    elsif params[:email]
      record = klass.classify.constantize.find_by_email(params[:email])
    else
      respond_invalid_parameters
    end

    if record
      if klass == 'post' && record && (record.hidden || record.soft_deleted || !record.approved)
        respond_no_record_found_for_id(klass)
      elsif klass == 'team' && (record.soft_banned && record.banned)
        respond_no_record_found_for_id(klass)
      else
        if (klass == 'earned_trophy' || klass == 'sticker') && params[:locale].present?
          _record = record.data(params[:locale])
        else
          _record = record.data
        end
        if klass == 'post' && params[:coach_id].present?
          _record[:liked] = record.has_been_liked(params[:coach_id])
        end
        respond_success_with_data(klass, _record)
      end
    else
      respond_no_record_found_for_id(klass)
    end
  end

  def list(klass)
    constantizedKlass = klass.classify.constantize
    records = []
    recordsFromDb = []

    # If the API call is asking for Posts, show the approrpiate list of posts based on the context parameter sent to /post/list...

    if klass == 'faq'
      # ...else if it's an FAQ class, get the right one based on the locale
      recordsFromDb = Faq.where("? = ANY (locales) and soft_deleted = false", params[:locale]).order('display_order ASC')
    else
      # ...and if not, then just get a listing of the requested object type.
      recordsFromDb = 
        constantizedKlass
        .offset((params[:offset].present?) ? params[:offset] : 0)
        .order(((klass.classify.constantize.column_names.include? 'display_order') ? 'display_order ASC' : 'created_at DESC'))
    end
      
    recordsFromDb.each do |record|
      records.append(record.data)
    end

    respond_success_with_data(klass.pluralize, records)
  end

  def delete(klass)
    if (SiteConfig.first.site_status == 'prelaunch' && (!params[:devBypass].present? || (params[:devBypass] != "true" && params[:devBypass] != true))) || SiteConfig.first.site_status == 'complete'
      respond_site_status(klass)
      return false
    end
    if (params[:id])
      record = klass.classify.constantize.find_by_id(params[:id])
    else 
      record = klass.classify.constantize.find_by_email(params[:email])
    end
    if record
      if record.update_attribute(:soft_deleted, true)
        if klass == 'team'
          record.hide_posts
        end
        respond_success(klass, record.id)
      else
        respond_failed_to_commit(klass, record)
      end
    else
      respond_no_record_found_for_id(klass)
    end
  end

end
