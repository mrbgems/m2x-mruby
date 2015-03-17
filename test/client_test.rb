def api_key
  '0123456789abcdef0123456789abcdef'
end

assert 'Client.new' do
  subject = M2X::Client.new
  assert_equal subject.api_key,     nil
  assert_equal subject.api_base,    M2X::Client::DEFAULT_API_BASE
  assert_equal subject.api_version, M2X::Client::DEFAULT_API_VERSION
end

assert 'Client.new(api_key)' do
  subject = M2X::Client.new(api_key)
  assert_equal subject.api_key,     api_key
  assert_equal subject.api_base,    M2X::Client::DEFAULT_API_BASE
  assert_equal subject.api_version, M2X::Client::DEFAULT_API_VERSION
end

assert 'Client#get' do
  subject = M2X::Client.new(api_key)
  res = subject.get('/status')
  assert_true res.is_a?(M2X::Client::Response)
  assert_true res.json.is_a?(Hash)
  assert_true res.success?
end
