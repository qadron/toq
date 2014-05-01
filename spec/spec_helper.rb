require 'timeout'
require_relative '../lib/arachni/rpc'
require_relative 'servers/server'

def cwd
    File.expand_path( File.dirname( __FILE__ ) )
end

def rpc_opts
    {
        host:       'localhost',
        port:       7331,
        token:      'superdupersecret',
        serializer: Marshal,
    }
end

def rpc_opts_with_ssl_primitives
    rpc_opts.merge(
        port:     7332,
        ssl_ca:   cwd + '/pems/cacert.pem',
        ssl_pkey: cwd + '/pems/client/key.pem',
        ssl_cert: cwd + '/pems/client/cert.pem'
    )
end

def rpc_opts_with_invalid_ssl_primitives
    rpc_opts_with_ssl_primitives.merge(
        ssl_pkey: cwd + '/pems/client/foo-key.pem',
        ssl_cert: cwd + '/pems/client/foo-cert.pem'
    )
end

def start_client( opts )
    Arachni::RPC::Client.new( opts )
end

def quiet_spawn( file )
    Process.spawn 'ruby', file, out: '/dev/null'
end

server_pids = []
RSpec.configure do |config|
    config.color = true
    config.add_formatter :documentation

    config.before( :suite ) do
        cwd = File.expand_path( File.dirname( __FILE__ ) )
        server_pids << quiet_spawn( File.join( cwd, 'servers', 'basic.rb' ) )
        server_pids << quiet_spawn( File.join( cwd, 'servers', 'with_ssl_primitives.rb' ) )
        server_pids << quiet_spawn( File.join( cwd, 'servers', 'unix_socket.rb' ) )
        server_pids.each { |pid| Process.detach( pid ) }
        sleep 2
    end

    config.after( :suite ) do
        server_pids.each { |pid| Process.kill( 'KILL', pid ) }
    end
end
