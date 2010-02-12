require 'helper'

class TestTexticle < TexticleTestCase
  def test_index_method
    x = fake_model
    x.class_eval do
      extend Texticle
      index do
        name
      end
    end
    assert_equal 1, x.full_text_indexes.length
    assert_equal 1, x.named_scopes.length

    x.full_text_indexes.first.create
    assert_equal :search, x.named_scopes.first.first
  end

  def test_named_index
    x = fake_model
    x.class_eval do
      extend Texticle
      index('awesome') do
        name
      end
    end
    assert_equal 1, x.full_text_indexes.length
    assert_equal 1, x.named_scopes.length

    x.full_text_indexes.first.create
    assert_equal :search_awesome, x.named_scopes.first.first
  end

  def test_named_scope_select
    x = fake_model
    x.class_eval do
      extend Texticle
      index('awesome') do
        name
        text 'A'
      end
    end
    ns = x.named_scopes.first[1].call('foo')
    assert_equal(["MATCH(`text`, `name`) AGAINST (?)", "'foo'"], ns[:conditions])
  end
 
  def test_named_scope_select
    x = fake_model
    x.class_eval do
      extend Texticle
      index('awesome') do
        name
        text 
      end
    end
    ns = x.named_scopes.first[1].call('foo')
    assert_equal(["MATCH(`name`, `text`) AGAINST (?)", "'foo'"], ns[:conditions])
  end
  
  def test_double_quoted_queries
    x = fake_model
    x.class_eval do
      extend Texticle
      index('awesome') do
        name
      end
    end
    
    ns = x.named_scopes.first[1].call('foo bar "foo bar"')
    puts "========================="
    p ns
    puts "========================="

    assert_equal(["MATCH(`name`) AGAINST (?)", "'foo' & 'bar' & 'foo bar'"], ns[:conditions])
  end
end
