require 'helper'

class TestFullTextIndex < TexticleTestCase
  def setup
    super
    @fm = fake_model
  end

  def test_initialize
    fti = Texticle::FullTextIndex.new('ft_index', @fm) do
      title
      body 'A'
    end
    assert_equal 'title',  fti.index_columns['none'].first
    assert_equal 'body',   fti.index_columns['A'].first
  end

  def test_destroy
    fti = Texticle::FullTextIndex.new('ft_index', @fm) do
      title
      body 'A'
    end
    fti.destroy
    assert @fm.connected
    assert_equal 1, @fm.executed.length
    executed =      @fm.executed.first
    assert_equal "ALTER TABLE fake_model DROP INDEX title", executed
  end

  def test_create
    fti = Texticle::FullTextIndex.new('ft_index', @fm) do
      title
      body 'A'
    end
    fti.create
    assert @fm.connected
    assert_equal 1, @fm.executed.length
    executed = @fm.executed.first
    assert_match fti.to_s, executed
    assert_equal("ALTER TABLE fake_model ADD FULLTEXT (`title`, `body`)", executed)
  end

  def test_columns
    fti = Texticle::FullTextIndex.new('ft_index', @fm) do
      title
      body 'A'
    end
    fti.create
    assert_equal(['title', 'body'], fti.columns)
  end
  
  def test_strings
    fti = Texticle::FullTextIndex.new('ft_index', @fm) do
      title
      body 'A'
    end
    fti.create
    assert_equal("`title`, `body`", fti.to_s)
  end


end
