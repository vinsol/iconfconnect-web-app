class Event < ActiveRecord::Base
  #FIXED: address should not be string, it should be text

  belongs_to :user
  
  has_many :sessions, dependent: :destroy
  has_many :attendes, through: :sessions, source: :attendes
  before_save :contains_session_outside_event_range

  #FIXME_AB: you should also rad about the patterns we can pass to paperclip styles. like we have > sign in following style, there are much more.
  has_attached_file :logo, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"

  validates_attachment_content_type :logo, :content_type => /\Aimage\/.*\Z/
  validates :name, :address, :city, :country, :contact_number, :description, presence: true
  validates :description, length: { maximum: 500 }
  #FIXME_AB: we may need to convert contact number to string. Keep it as it is for now
  validates :contact_number, numericality: { only_integer: true }
  validate :event_date_valid

  scope :enabled, -> { where(enable: true) }
  #FIXED: as discussed we don't need following order_by scope. In case we need then it should be:   scope :order_by_start_date, -> (sort = 'ASC') { order(start_date: sort) }
  scope :order_by_start_date, -> (sort) { order(start_date: sort) }

  #FIXED: rename it to live_and_upcoming
  scope :live_and_upcoming, -> { where("end_date >= ?", Time.current) }
  scope :past, -> { where("end_date < ?", Time.current) }
  scope :search, -> (query) { where("name LIKE :query OR city LIKE :query OR country LIKE :query",
                            query: "%#{ query }%") }

  # def get_attendes
  #   #FIXED: we can do it through associations like we did from event. [90% sure]
  #   sessions.collect do |session|
  #     session.attendes
  #   end.flatten.uniq
  # end

  #FIXED: should be named as live_and_upcoming
  def live_and_upcoming?
    end_date >= Time.current 
  end

  def past?
    end_date <= Time.current
  end

  def owner?(user)
    user_id == user.id
  end

  def to_param
    "#{id}-#{name}"
  end

  private
  #FIXED: low priority: think about a better name
    def event_date_valid
      #FIXED: if start_date_unacceptable? or if start_date_invalid?
      if start_date_unacceptable?
        errors.add(:start_date, ' Should be less than end date and Should be a future date')
      end
    end
    
    def start_date_unacceptable?
      (start_date < Time.current) || (start_date >= end_date)
    end

    def contains_session_outside_event_range
      sessions.each do |session|
        if session.start_date < start_date
          errors.add(:start_date, 'Cannot update the event as it contains session')
          return false
        elsif session.end_date > end_date
          errors.add(:end_date, 'Cannot update the event as it contains session')
          return false
        end  
      end        
    end

  #FIXED: When I am updating any event, we should check for session time too. It should not allow event to shrink beyond the session times

end
