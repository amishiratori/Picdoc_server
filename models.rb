ActiveRecord::Base.establish_connection(ENV['DATABASE_URL']||"sqlite3:db/development.db")
class Pictogram < ActiveRecord::Base

end

class Language < ActiveRecord::Base

end
