class User < ActiveRecord::Base
  validates :name, length: { minimum: 1, maximum: 30 }
  validates :name, format: { with: /\A[a-zA-Z]+\z/, message: "usernmae must be one or more letters." }

  validates :name, uniqueness: true

  def initialize
    super
  end

end
