module PasswordComplexity
  extend ActiveSupport::Concern

  COMPLEXITY_REGEX = /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^a-zA-Z0-9]).{8,}\z/

  included do
    validate :password_complexity, if: :password_required?
  end

  private

  def password_complexity
    return if password.blank?
    return if password.match?(COMPLEXITY_REGEX)
    errors.add(:password, 'は半角英大文字・小文字・数字・記号をそれぞれ1文字以上含む8文字以上で設定してください')
  end
end
