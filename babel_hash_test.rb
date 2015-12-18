require 'minitest/autorun'
require 'minitest/pride'
require 'babel_hash'

class BabelHashTest < MiniTest::Unit::TestCase
  def setup
    @opts = {}
    @map = {
      'address'       => 'primaryEmail',
      'password'      => 'password',
      'first_name'    => 'name.givenName',
      'last_name'     => 'name.familyName',
      'department'    => 'organizations[0].department',
      'title'         => 'organizations[0].title',
      'privacy'       => 'includeInGlobalAddressList',
      'org_unit_path' => 'orgUnitPath'
    }
  end

  def translator
    @translator ||= BabelHash.new(@map, @opts)
  end

  def google_api_hash
    {
      'primaryEmail' => 'milton.waddams@initech.com',
      'password' => 'No salt',
      'name' => {
        'givenName' => 'Milton',
        'familyName' => 'Waddams'
      },
      'organizations' => [
        {
          'department' => 'Reporting',
          'title' => 'Collator'
        }
      ],
      'includeInGlobalAddressList' => true,
      'orgUnitPath' => '/BasementDwellers'
    }
  end

  def code_noble_hash
    {
      'address'       => 'milton.waddams@initech.com',
      'password'      => 'No salt',
      'first_name'    => 'Milton',
      'last_name'     => 'Waddams',
      'department'    => 'Reporting',
      'title'         => 'Collator',
      'privacy'       => true,
      'org_unit_path' => '/BasementDwellers'
    }
  end

  def test_translate_top_level_keys
    assert_equal 'milton.waddams@initech.com',
      translator.translate(code_noble_hash)['primaryEmail']
  end

  def test_translate_deep_keys
    assert_equal 'Milton',
      translator.translate(code_noble_hash)['name']['givenName']
  end

  def test_translate_array_plumbing
    assert_kind_of Array, translator.translate(code_noble_hash)['organizations']
    assert_equal 'Reporting',
      translator.translate(code_noble_hash)['organizations'][0]['department']
  end

  def test_reverse_translate_top_level_keys
    translator.reverse!

    assert_equal 'milton.waddams@initech.com',
      translator.translate(google_api_hash)['address']
  end

  def test_reverse_translate_deep_keys
    translator.reverse!

    assert_equal 'Milton',
      translator.translate(google_api_hash)['first_name']
  end

  def test_reverse_translate_array_plumbing
    translator.reverse!

    assert_equal 'Reporting',
      translator.translate(google_api_hash)['department']
  end

  def test_invert_booleans
    @opts = { invert_booleans: true }

    refute translator.translate(code_noble_hash)['includeInGlobalAddressList']
  end

  def test_keypaths_work_with_symbol_keys
    api_hash = {
      password: 'No salt',
      first_name: 'Milton',
      title: 'Collator',
    }

    assert_equal 'No salt', translator.translate(api_hash)[:password]
    assert_equal 'Milton',
      translator.translate(api_hash)[:name][:givenName]
    assert_equal 'Collator',
      translator.translate(api_hash)[:organizations][0][:title]
  end

  def test_reverse_keypaths_work_with_symbols
    api_hash = {
      password: 'No salt',
      name: {
        givenName: 'Milton'
      },
      organizations: [
        {
          title: 'Collator'
        }
      ]
    }

    translator.reverse!

    assert_equal 'No salt', translator.translate(api_hash)[:password]
    assert_equal 'Milton', translator.translate(api_hash)[:first_name]
    assert_equal 'Collator', translator.translate(api_hash)[:title]
  end

  def test_deep_nest_to_deep_nest
    @map = { 'deeply.nested.keys' => 'other.keys.and.stuff' }
    hash = { deeply: { nested: { keys: [1,2] } } }

    assert_equal [1,2], translator.translate(hash)[:other][:keys][:and][:stuff]
  end

  def test_array_values
    @map = { 'funny.things[1]' => 'the.funniest.thing' }
    hash = { funny: { things: %i(ewoks kittens clowns) } }

    assert_equal :kittens, translator.translate(hash)[:the][:funniest][:thing]
  end
end
