class Team < ActiveRecord::Base

  Rack::Timeout.service_timeout = 29
  attr_accessible :name, :arena, :avatar, :coach_id, :coach, :program, :slug, :postalcode, :clublevel, :frame_level, :star_level, :activity_score, :winner_week_of, :chapter_complete_email, :chapter_nudge, :extra_credit_nudge, :total_activity_score, :contender, :day_streak, :week_streak, :existing_avatar_url

  after_create :create_token, :createPrettyURL, :create_earned_trophies
  after_destroy :destroy_posts
  before_update :checkPrettyURL

  has_attached_file :avatar, :convert_options => {:all => '-auto-orient'}, styles: {small: "100x100", med: "200x200", large: "400x400", extra_large: "1600x1600"}, :preserve_files => "true", :s3_protocol => :https, :s3_headers => {'Cache-Control' => 'max-age=315576000', 'Expires' => 10.years.from_now.httpdate}, :default_url => "http://ua-hockey-2019.s3.amazonaws.com/default-avatar.svg"
  validates_attachment_content_type :avatar, :content_type => [/image/]
  validates_attachment_size :avatar, :less_than => 10.megabyte

  has_many :posts
  has_many :likes
  has_many :coaches
  has_many :earned_trophies

  def check_for_avatar
    @existing_team = ExistingTeam.where(email: self.coaches.where(is_uploader: false).first.email).first

    puts self.coaches.where(is_uploader: false).first.email

    if @existing_team
      self.existing_avatar_url = @existing_team.team_avatar_url
      self.save
    end
  end

  def vets_trophy
    if ExistingTeam.where(email: self.coaches.first.email).first != nil
      @trophy = Trophy.where(title: "STC Vets").first
      if EarnedTrophy.where(team_id: self.id, trophy_id: @trophy.id).length < 1
        EarnedTrophy.create(team_id: self.id, trophy_id: @trophy.id)
        @trophy = Trophy.where(title: "STC Vets").first
        @earned_trophy = EarnedTrophy.where(team_id: self.id, trophy_id: @trophy.id).first
        if !@earned_trophy.earned
          @earned_trophy.increment_and_earn
        end
      end
    else

    end
  end

  def create_token
    token = ''

    loop do
      token = ('A'..'Z').to_a.shuffle[0,5].join
      break if (Team.where({ :token => token }).count == 0)
    end

    self.token = token
    self.save!
  end

  def create_earned_trophies
    Trophy.all.each do |trophy|
      if trophy.title == "STC Vets"

      elsif trophy.title == "Teamwork Makes The Dream Work"
        if EarnedTrophy.where(team_id: self.id, trophy_id: trophy.id).length < 1
          EarnedTrophy.create(team_id: self.id, trophy_id: trophy.id, progress: 1)
        end
      else
        if EarnedTrophy.where(team_id: self.id, trophy_id: trophy.id).length < 1
          EarnedTrophy.create(team_id: self.id, trophy_id: trophy.id)
        end
      end
    end
  end

  # Create a pretty URL slug for this team so its page can
  # be accessed via /teams/team_name
  def createPrettyURL
    self.slug = getAvailablePrettyURLSlug()
    self.save
  end

  # Because a team update may have included the name, we may need to
  # update the slug for it in the database
  def checkPrettyURL
    if (self.slug != getAvailablePrettyURLSlug())
      self.slug = getAvailablePrettyURLSlug()
    end
  end

  def self.valid_attributes(params)
    params[:name] && params[:arena] && params[:token] && params[:program]
  end

  def data
    {
        id: self.id,
        team: self,
        posts: self.posts.where({ :approved => true, :soft_deleted => false }),
        posts_1: self.posts.where({ :approved => true, :challenge_id => 1, :soft_deleted => false }).length,
        posts_2: self.posts.where({ :approved => true, :challenge_id => 2, :soft_deleted => false }).length,
        posts_3: self.posts.where({ :approved => true, :challenge_id => 3, :soft_deleted => false }).length,
        posts_4: self.posts.where({ :approved => true, :challenge_id => 4, :soft_deleted => false }).length,
        posts_5: self.posts.where({ :approved => true, :challenge_id => 5, :soft_deleted => false }).length,
        extra_credit: self.posts.where({ :approved => true}).count - self.frame_level,
        team_logo: self.build_logo,
        team_featured: Post.team_highlights(self.id).count,
        team_logo_without_frame: self.existing_avatar_url.blank? ? self.avatar.url : self.existing_avatar_url,
        team_mates: self.coaches.count,
        coach: self.coaches
    }
  end

  def can_post?
    !self.soft_banned && !self.soft_deleted && !self.banned
  end

  def write(params)
    update_attributes(not_nil_params(params))
  end

  def destroy_posts
    self.posts.each do |post|
      post.destroy
    end
  end

  def hide_posts
    self.posts.each do |post|
      post.update_attribute(:hidden, true)
    end
  end

  def unhide_posts
    self.posts.each do |post|
      post.update_attribute(:hidden, false)
    end
  end

  def get_earned_trophies
    return self.earned_trophies
  end

  def get_unlocked_trophies
    @trophy_array = self.earned_trophies.where(earned: true).pluck("trophy_id")
    return Trophy.where(id: @trophy_array)
  end

  def get_unlocked_stickers
    @trophy_array = self.earned_trophies.where(earned: true).pluck("trophy_id")
    return Sticker.where(trophy_id: @trophy_array).includes(:trophy).order("trophies.display_order asc, trophies.tier asc")
  end

  def soft_delete
    self.update_attribute(:soft_deleted, true)
    self.hide_posts
  end

  def unsoft_delete
    self.update_attribute(:soft_deleted, false)
    self.unhide_posts
  end

  def get_post_ids(current_user=nil, offset=0)
    posts = Post.where("posts.complete = true and posts.user_id = ?", self.id, self.id).offset(offset).limit(500).group("posts.id")
    posts.sort do |p1, p2|
      p2.created_at <=> p1.created_at
    end
  end

  def get_total_post_count(user)
    Post.where("posts.complete = true and posts.user_id = ?", user.id, user.id).group("posts.id").count
  end

  def get_user_post_ids(user)
    Post.where("posts.complete = true and posts.user_id = ?", user.id).limit(500).group("posts.id").order('posts.created_at DESC')
  end

  def get_current_post
    Post.where('user_id = ? AND zencoder_job_id = ?', self.id, self.current_video_job_id).first()
  end

  def ban
    self.update_attribute(:banned, true)
    hide_posts
  end

  def unban
    self.update_attribute(:banned, false)
    unhide_posts
  end

  def soft_ban
    self.update_attribute(:soft_banned, true)
    hide_posts
  end

  def unsoft_ban
    self.update_attribute(:soft_banned, false)
    unhide_posts
  end

  def profile_feed(offset)
    records = []
    self.posts.where(:soft_deleted => false).where(:hidden => false).where(:approved => true).offset(offset).order('created_at DESC').limit(30).each do |p|
      records.append(p.data)
    end
    {feed: records, feedTotal: self.posts.where(:soft_deleted => false).where(:hidden => false).where(:approved => true).count, feedOffset: offset}
  end

  def calculate_portrait
    story_challenges = (Post.where('team_id = ? AND approved = ? and soft_deleted = ?', self.id, true, false).where('challenge_id != 5').select(:challenge_id).uniq.count)
    stars = 0
    Post.where('team_id = ? AND approved = ?', self.id, true).group(:challenge_id).count.each do |c|
      if c[1] > 5
        stars = stars + 1
      end
    end
    self.frame_level = story_challenges
    self.star_level = stars
    self.save
  end

  def calculate_activity_score
    recent_coaches = self.coaches.recent.select(:created_at)
    recent_approved = self.posts.recently_approved.select(:created_at)
    recent_featured = self.posts.recently_featured.select(:created_at)

    recent_activity = recent_coaches + recent_approved + recent_featured
    activity_score = 0
    recent_activity.each do |a|
      if (Time.now - a.created_at) < 1.day
        activity_score = activity_score + 5
      elsif (Time.now - a.created_at) < 2.day
        activity_score = activity_score + 4
      else
        activity_score = activity_score + 3
      end
    end

    self.activity_score = activity_score
    self.save
  end

  def build_logo
    # Figure out which program the team's in so we know which color frame and stars to display
    case Team.find(self.id).program # Why do I have to do it like this?!
    when 'toronto'
      locale = 'to'
    when 'montreal'
      locale = 'ce'
    when 'edmonton'
      locale = 'ed'
    end

    @avatar_url = self.existing_avatar_url.blank? || self.existing_avatar_url.include?('ua-hockey-2017')  ? self.avatar.url : self.existing_avatar_url

    @frameImage = '<img src="/portrait/frame-' + (self.frame_level).to_s + '.' + locale + '.svg"/>'
    @starsImage = self.frame_level == 0 ? '' : '<img src="/portrait/stars-' + (self.star_level).to_s + '.' + locale + '.svg"/>'

    '<div class="avatar">
       <div class="team-logo">
         <img src="' +  @avatar_url + '" class="logo" />
       </div>

       <div class="frame">' + @frameImage + '</div>
     </div>'

  end

  private

  def getAvailablePrettyURLSlug
    slug = self.name.strip.downcase.gsub(/[ ]+/, '_').gsub(/[^0-9A-Za-z_]/, '')
    suffix = ''

    while (Team.where("slug = ? and id != ?", "#{slug}#{suffix}", self.id).length > 0) do
      suffix = (suffix == '') ? 2 : suffix + 1
    end

    return (suffix == '') ? slug : "#{slug}#{suffix}"
  end

  def not_nil_params(params)
    _temp = {}
    params.each do |p, v|
      if ['email', 'first_name', 'last_name', 'username', 'avatar', 'coach_id', 'age', 'birthday', 'province', 'gender', 'sports'].to_a.include? p
        _temp[p] = v
      end
    end
    _temp
  end

  def username_uniqueness
    existing_username = !!Team.where('username = ? AND id != ?', self.username, self.id).first

    if existing_username
      errors.add(:username, 'Sorry, the username that you entered is already registered. Please try a different one.')
    end
  end

end
