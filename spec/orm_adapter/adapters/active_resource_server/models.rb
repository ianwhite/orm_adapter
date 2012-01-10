class User < ActiveRecord::Base
  has_many :notes, :foreign_key => 'owner_id'
end

class Note < ActiveRecord::Base
  belongs_to :owner, :class_name => "User"
end
