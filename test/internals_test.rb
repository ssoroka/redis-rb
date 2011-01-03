# encoding: UTF-8

require File.expand_path("./helper", File.dirname(__FILE__))
require File.expand_path("./redis_mock", File.dirname(__FILE__))

include RedisMock::Helper

setup do
  log = StringIO.new

  [Redis.new(OPTIONS.merge(:logger => ::Logger.new(log))), log]
end

$TEST_PIPELINING = true
$TEST_INSPECT    = true

load File.expand_path("./lint/internals.rb", File.dirname(__FILE__))

test "Redis.current" do
  Redis.current.set("foo", "bar")

  assert "bar" == Redis.current.get("foo")

  Redis.current = Redis.new(OPTIONS.merge(:db => 14))

  assert Redis.current.get("foo").nil?
end

test "can be dup'ed to create a new connection" do |r1, _|
  clients = r1.info["connected_clients"].to_i

  r2 = r1.dup
  r2.ping

  assert_equal clients + 1, r1.info["connected_clients"].to_i
end
