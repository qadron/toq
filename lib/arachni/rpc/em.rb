=begin
                  Arachni-RPC
  Copyright (c) 2011 Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>

  This is free software; you can copy and distribute and modify
  this program under the term of the GPL v2.0 License
  (See LICENSE file for details)

=end

require 'eventmachine'

module Arachni
module RPC

#
# Provides some convinient methods for EventMachine's Reactor.
#
# @author: Tasos "Zapotek" Laskos
#                                      <tasos.laskos@gmail.com>
#                                      <zapotek@segfault.gr>
# @version: 0.1
#
module EM

    #
    # Inits method variables for the Reactor tasks and its Mutex.
    #
    def init
        @@reactor_tasks_mutex ||= Mutex.new
        @@reactor_tasks ||= []
    end

    #
    # Adds a block in the Reactor.
    #
    # @param    [Proc]    &block    block to be included in the Reactor loop
    #
    def add_to_reactor( &block )
        self.init

        @@reactor_tasks_mutex.lock
        @@reactor_tasks << block

        ensure_em_running!
    ensure
        @@reactor_tasks_mutex.unlock
    end

    #
    # Blocks until the Reactor stops running
    #
    def block!
        ::EM.reactor_thread.join
    end

    #
    # Puts the Reactor in its own thread and runs it.
    #
    # It also runs all blocks sent to {#add_to_reactor}.
    #
    def ensure_em_running!
        self.init

        if !::EM::reactor_running?
            q = Queue.new
            Thread.new do
                ::EM::run do
                    @@reactor_tasks.each { |task| task.call }
                    q << true
                end
            end
            q.pop
        end
    end

    extend self
end
end
end
