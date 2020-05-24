class User < ApplicationRecord
  validates :name, presence: true
  validates_numericality_of :balance, greater_than_or_equal_to: 0
end

class TransferService
  def self.call(from_user_id, to_user_id, amount)
    from_user = User.find(from_user_id)
    to_user = User.find(to_user_id)

    from_user.with_lock do
      to_user.with_lock do
        if from_user.balance < amount
          raise ArgumentError, 'Not enough money to make a transfer'
        end

        from_user.balance -= amount
        to_user.balance += amount
        from_user.save!
        to_user.save!
      end
    end
  end
end
