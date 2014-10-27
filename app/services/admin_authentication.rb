class AdminAuthentication
  include Procto.call

  def initialize(username, password)
    @username, @password = username.freeze, password.freeze
  end

  def call
    @username.eql?('admin') && @password.eql?(ENVied.ADMIN_PASSWORD)
  end
end
