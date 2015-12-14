class DefaultActions
  attr_reader :actions
  def initialize(resource)
    @resource = resource.to_s
    @resource_id = @resource.singularize + "_id"
    @actions = all
  end

  def parse_action_restrictions(restrictions_hash)
    raise(ArgumentError) if restrictions_hash.size > 1
    send(:only, restrictions_hash[:only]) if restrictions_hash[:only]
    send(:except, restrictions_hash[:except]) if restrictions_hash[:except]
  end

  def index
    { index: { suffix: "$", method: :get } }
  end

  def show
    { show: { suffix: "/(?<#{@resource_id}>\\d+)$", method: :post } }
  end

  def new
    { new: { suffix: "/new$", method: :get } }
  end

  def create
    { create: { suffix: "$", method: :post } }
  end

  def edit
    { edit: { suffix: "/(?<#{@resource_id}>\\d+)/edit$", method: :get } }
  end

  def update
    { update: { suffix: "/(?<#{@resource_id}>\\d+)$", method: :put } }
  end

  def destroy
    { destroy: { suffix: "/(?<#{@resource_id}>\\d+)$", method: :delete } }
  end

  private

    def all
      DefaultActions.instance_methods(false).drop(2).reduce({}) do |accum, method|
        accum.merge(send(method))
      end
    end

    def only(action_names)
      @actions.keep_if { |key, _| action_names.include?(key) }
    end

    def except(action_names)
      @actions.keep_if { |key, _| !action_names.include?(key) }
    end

end
