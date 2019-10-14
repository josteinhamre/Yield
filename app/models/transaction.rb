class Transaction < ApplicationRecord
  belongs_to :account
  belongs_to :category
  monetize :amount_cents
  has_one :user, through: :account
  validates :datetime, :info, :amount_cents, presence: true
  after_save :auto_categorize

  def auto_categorize
    return unless category.name == 'No Category'

    require 'string/similarity'
    cat_collection = Hash.new(0)
    # puts self
    user.transactions.where.not(approved_at: nil).each do |trans|
      value = String::Similarity.levenshtein_distance(info[0, 15], trans.info[0, 15])
      cat_collection[trans.category] += (11 - value) if value < 11
    end
    unless cat_collection.empty?
      chosen = cat_collection.max_by{ |_key, value| value }.first
      self.category = chosen
      p self.info
      p chosen
      p cat_collection[chosen]
      save if category.name != 'No Category' && cat_collection[chosen] > 30
    end
    category.name
  end


  # def auto_categorize
  #   return unless category.name == 'No Category'

  #   require 'string/similarity'
  #   cat_collection = []
  #   puts self
  #   user.transactions.where.not(approved_at: nil).each do |trans|
  #     value = String::Similarity.levenshtein_distance(info[0, 15], trans.info[0, 15])
  #     cat_collection << trans.category if value < 9
  #   end
  #   puts cat_collection
  #   counts = Hash.new(0)
  #   cat_collection.each { |name| counts[name] += 1 }
  #   unless counts.empty?
  #     self.category = counts.max_by{ |_key, value| value }.first
  #     save if category.name != 'No Category'
  #   end
  #   category
  # end

  def self.import_dnb(file, user)
    require 'csv'
    CSV.foreach(file.path, headers: true, col_sep: ';', encoding: 'ISO-8859-1') do |row|
      if row[1].match?(/(Varekjøp)(.*)(Dato .*)/)
        dnb_varekjop(row, user)
      elsif row[1].match?(/(Visa|Lån|Kontoregulering|Overføring)\s*(\d*)(.*)/)
        dnb_other(row, user)
      elsif row[1].match?(/Reservert/)
        puts "Waiting to parse #{row[1]}, missing full information"
      else
        puts "Unable to parse #{row[1]}"
      end
    end
  end

  def self.dnb_varekjop(row, user)
    match = row[1].match(/(Varekjøp)(.*)(Dato .*)/)
    trans = Transaction.new
    trans.info = match[2].strip
    trans.datetime = Time.strptime(row[0][6, 9] + '.' + match[3][5, 15], "%Y.%d.%m kl. %H.%M")
    trans.account = user.accounts.first
    trans.category = user.no_cat
    trans.csv_row_id = row
    row[3] == "" ? trans.amount = row[4] : trans.amount = "-#{row[3]}"
    trans.save
  end

  def self.dnb_other(row, user)
    match = row[1].match(/(Visa|Lån|Kontoregulering|Overføring)\s*(\d*)(.*)/)
    trans = Transaction.new
    trans.info = "#{match[1].strip} - #{match[3].strip}"
    trans.datetime = Time.strptime("#{row[0]}.12.00", "%d.%m.%Y.%H.%M")
    trans.account = user.accounts.first
    trans.category = user.no_cat
    trans.csv_row_id = row
    row[3] == "" ? trans.amount = row[4] : trans.amount = "-#{row[3]}"
    trans.save
  end
end
