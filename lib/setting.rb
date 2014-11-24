require 'settingslogic'

class Setting < Settingslogic
  source    TK_ROOT_DIR + './config/application.yml'
  namespace TK_ENV

  def env
    TK_ENV
  end
end
