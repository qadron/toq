=begin
                  Arachni-RPC
  Copyright (c) 2011 Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>

  This is free software; you can copy and distribute and modify
  this program under the term of the GPL v2.0 License
  (See LICENSE file for details)

=end

module Arachni
module RPC
module Exceptions
    class ConnectionError < ::Exception; end
    class RemoteException < ::Exception; end
    class InvalidObject < ::Exception; end
    class InvalidMethod < ::Exception; end
    class InvalidToken  < ::Exception; end
end
end
end