
class Url < PersistentObject
  def to_s
    'Original: ' + self.original + ', Shortified: ' + self.shortified
  end
end
