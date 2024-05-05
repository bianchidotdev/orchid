defmodule OrchidSchema do
  use Boundary,
    deps: [
      Ecto.Changeset
    ],
    exports: [
      Cluster,
      Service,
      Source
    ]
end
