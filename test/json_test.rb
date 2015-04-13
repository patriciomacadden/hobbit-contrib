require 'helper'

scope Hobbit::Render do
  setup do
    mock_app do
      include Hobbit::JSON

      get('/') { json({'hello' => 'world'}) }
    end
  end

  scope '#json' do
    test 'returns json response' do
      get '/'
      assert last_response.ok?
      assert last_response.headers['Content-Type'] == 'application/json'
      assert JSON.parse(last_response.body) == {'hello' => 'world'}
    end
  end
end
