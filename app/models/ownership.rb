class Ownership < ActiveRecord::Base
  default_scope { order('created_at ASC') }
  belongs_to :owner, polymorphic: true
  belongs_to :item, polymorphic: true

  has_many :ancestries, :dependent => :destroy, :class_name => "OwnershipAncestry"

  validates_presence_of :owner, unless: Proc.new { |ownership| item.present? }
  validates_presence_of :item, unless: Proc.new { |ownership| owner.present? }

  after_create :create_ancestry
  after_destroy :destroy_orphans

  def global_owner
    self.owner.to_global_id if self.owner.present?
  end
  def global_owner=(owner)
    self.owner = GlobalID::Locator.locate owner
  end

  private

  def create_ancestry
    if owner.owners.any?
      owner.owners.each do |ownership|
        ownership.ancestries.each do |ancestry|
          @ancestry = ancestry.children.create(:ownership => self, :item_class => owner.class.name)
        end
      end
    else
      @ancestry = OwnershipAncestry.create(:ownership => self, :item_class => owner.class.name)
    end
    if item.ownerships.any?
      item.ownerships.each do |ownership|
        ownership.ancestries.each do |ancestry|
          @descendant = @ancestry
          ancestry.subtree.each do |descendant|
            if ancestry.is_root?
              descendant.update_attributes(:ancestry => "#{@ancestry.id}" + (descendant.ancestry.blank? ? "" : "/" + descendant.ancestry), :ancestry_depth => descendant.ancestry_depth + 1)
            else
              @descendant = @descendant.children.create(:ownership => descendant.ownership, :item_class => descendant.item_class)
            end
          end
        end
      end
    end
  end

  def destroy_orphans
    unless self.item.class.name == "User"
      self.item.destroy if self.item.owners.empty?
    end
  end

end
