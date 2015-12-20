require 'key_bridge/keypath_hash'

module KeyBridge
  class KeypathHashTest < Minitest::Test
    def subject
      @subject ||= KeyBridge::KeypathHash.new(@source || {})
    end

    def test_reads_one_level_deep
      @source = { favorite_film: 'Hunt for Red October' }

      assert_equal 'Hunt for Red October', subject['favorite_film']
    end

    def test_writes_one_level_deep
      @source = { favorite_film: 'Hunt for Red October' }
      subject['favorite_film'] = 'Coherence'

      assert_equal 'Coherence', subject['favorite_film']
    end

    def test_reads_many_levels_deep
      @source = { a: { b: { c: { d: { e: 'next is f!' } } } } }

      assert_equal 'next is f!', subject['a.b.c.d.e']
    end

    def test_writes_many_levels_deep
      @source = { a: { b: { c: { d: { e: 'next is f!' } } } } }
      subject['a.b.c.d.e'] = 'who cares about f'

      assert_equal 'who cares about f', subject['a.b.c.d.e']
    end

    def test_writes_new_keys_one_level_deep
      @source = { favorite_film: 'Hunt for Red October' }
      subject['second_favorite_film'] = 'Coherence'

      assert_equal 'Hunt for Red October', subject['favorite_film']
      assert_equal 'Coherence', subject['second_favorite_film']
    end

    def test_writes_new_keys_many_levels_deep
      @source = { a: { b: { c: { d: { e: 'next is f!' } } } } }
      subject['a.b.c.one.two'] = 'totally random'

      assert_equal 'next is f!', subject['a.b.c.d.e']
      assert_equal 'totally random', subject['a.b.c.one.two']
    end

    def test_reads_arrays_at_index_one_level_deep
      @source = { movies: ['Hunt for Red October', 'Coherence'] }

      assert_equal 'Hunt for Red October', subject['movies[0]']
    end

    def test_reads_arrays_at_index_many_levels_deep
      @source = {
        favorite: {
          movies: ['Hunt for Red October', 'Coherence']
        }
      }

      assert_equal 'Hunt for Red October', subject['favorite.movies[0]']
    end

    def test_reads_keypaths_after_array_at_index
      @source = {
        favorite: {
          movies: [
            { title: 'Hunt for Red October' },
            { title: 'Coherence' }
          ]
        }
      }

      assert_equal 'Hunt for Red October', subject['favorite.movies[0].title']
    end

    def test_writes_arrays_one_level_deep
      @source = { movies: ['Hunt for Red October', 'Coherence'] }
      subject['movies[]'] = 'The Incredibles'

      assert_equal([
        'Hunt for Red October',
        'Coherence',
        'The Incredibles'
      ], subject['movies'])
    end

    def test_writes_arrays_at_index_one_level_deep
      @source = { movies: ['Hunt for Red October', 'Coherence'] }
      subject['movies[1]'] = 'The Incredibles'

      assert_equal ['Hunt for Red October', 'The Incredibles'], subject['movies']
    end

    def test_writes_arrays_at_index_many_levels_deep
      @source = {
        date_night: {
          movies: [
            { title: 'Hunt for Red October', snacks: [:pizza] },
            { title: 'Coherence', snacks: [:popcorn, :candy] }
          ]
        }
      }
      subject['date_night.movies[0].snacks[]'] = :popcorn

      assert_equal [:pizza, :popcorn], subject['date_night.movies[0].snacks']
    end
  end
end
