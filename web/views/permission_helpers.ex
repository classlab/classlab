defmodule Classlab.PermissionHelpers do
  @moduledoc """
  Helper to decide if current user has the permissions to see specific html.
  """

  def has_permission?(memberships, role_ids) when is_list(role_ids) do
    membership_roles = Enum.map(memberships, fn(membership) -> membership.role_id end)
    Enum.any?(role_ids, &Enum.member?(membership_roles, &1))
  end

  def has_permission?(memberships, role_ids, event) when is_list(role_ids) do
    membership_roles = Enum.filter_map(
      memberships,
      fn(membership) -> membership.event_id == event.id end,
      fn(membership) -> membership.role_id end
    )
    Enum.any?(role_ids, &Enum.member?(membership_roles, &1))
  end

end
