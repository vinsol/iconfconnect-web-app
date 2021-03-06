class User < ActiveRecord::Base
  #FIXME_AB: think about dependent optoin and handle it
  has_many :events
  has_many :user_session_associations
  has_many :attending_events, through: :user_session_associations, source: :event
  has_many :attending_sessions, through: :user_session_associations, source: :session

  validates :name, presence: true

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.id = auth['uid']
      if auth['info']
        user.handle = auth['info']['urls']['Twitter']
        #FIXME_AB: Following line contradict with your validation on name
        user.name = auth['info']['name'] || ""
      end
    end
  end
end
