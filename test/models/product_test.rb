require "test_helper"

class ProductTest < ActiveSupport::TestCase
  fixtures :products

  def new_product(filename, content_type)
    Product.new(
      title: 'My book title',
      description: 'a description about my book',
      price: 1
    ).tap do |product|
      product.image.attach(
        io: File.open("test/fixtures/files/#{filename}"), filename:, content_type:
      )
    end
  end
  test 'product attributes must not be empty' do
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:price].any?
    assert product.errors[:image].any?
  end

  test 'product price must be positive' do
    product = Product.new(title: 'My Book Title', description: 'a description about the book')
    product.image.attach(io: File.open('test/fixtures/files/lorem.jpg'), filename: 'lorem.jpg', content_type: 'image/jpg')
    product.price = -1
    assert product.invalid?
    assert_equal [ 'must be greater than or equal to 0.01' ], product.errors[:price]

    product.price = 1
    assert product.valid?
  end

  test 'image url' do
    product = new_product('lorem.jpg', 'image/jpg')
    assert product.valid?, 'image/jpg must be valid'

    product = new_product('logo.svg', 'image/svg+xml')
    assert_not product.valid?, 'image/svg+xml must be invalid'
  end

  test 'product is not valid without a unique title' do
    product = Product.new(
      title: products(:pragprog).title,
      description: 'a description of the book',
      price: 1
    )
    product.image.attach(io: File.open("test/fixtures/files/lorem.jpg"), filename: 'lorem.jpg', content_type: 'image/jpeg')
    assert product.invalid?
    assert_equal [ 'has already been taken' ], product.errors[:title]
  end
end
