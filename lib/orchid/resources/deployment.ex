defmodule Orchid.Resources.Deployment do
  use Ash.Resource,
    domain: Orchid,
    data_layer: Ash.DataLayer.Mnesia,
    extensions: [AshStateMachine]

  attributes do
    uuid_primary_key :id

    # , :blue_green, :canary]]
    attribute :strategy, :atom, constraints: [one_of: [:rolling]], default: :rolling
    attribute :service_name, :string do
      allow_nil? false
    end
    # point in time definition of the service
    # of type OrchidSchema.Service
    attribute :service, :map do
      allow_nil? false
    end

    timestamps()
  end

  state_machine do
    initial_states [:pending]
    default_initial_state :pending

    transitions do
      transition(:deploy, from: :pending, to: :deploying)
      transition(:deployed, from: :deploying, to: :deployed)
      transition(:failed, from: :deploying, to: :failed)
    end
  end

  actions do
    read :active do
      prepare build(limit: 10, sort: [inserted_at: :asc])

      # fetch the oldest pending deployment for each service
      filter expr(state in [:pending, :deploying])
      # distinct(:service_name)
      # distinct_sort(:inserted_at, :asc)
    end

    read :last_by_service do
      prepare build(limit: 1, sort: [created_at: :desc])

      filter expr(service_name == :service_name)
    end

    create :create do
      accept [:service_name, :strategy, :service]
    end

    update :deploy do
      change transition_state(:deploying)
    end

    update :deployed do
      change transition_state(:deployed)
    end

    update :failed do
      change transition_state(:failed)
    end
  end
end
