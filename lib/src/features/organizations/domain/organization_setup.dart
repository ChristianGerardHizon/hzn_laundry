/// First-branch payload collected by the create-organization setup wizard.
class OrganizationSetupBranch {
  const OrganizationSetupBranch({
    required this.name,
    required this.address,
    required this.contactNumber,
    this.operatingHours,
    this.cutOffTime,
    this.incentiveAmount = 5,
    this.incentivePerServiceItems = 200,
    required this.tiers,
  });

  final String name;
  final String address;
  final String contactNumber;
  final String? operatingHours;
  final String? cutOffTime;
  final num incentiveAmount;
  final num incentivePerServiceItems;
  final List<OrganizationSetupTier> tiers;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'contactNumber': contactNumber,
      'operatingHours': operatingHours ?? '',
      'cutOffTime': cutOffTime ?? '',
      'incentiveAmount': incentiveAmount,
      'incentivePerServiceItems': incentivePerServiceItems,
      'tiers': tiers.map((t) => t.toJson()).toList(),
    };
  }
}

class OrganizationSetupTier {
  const OrganizationSetupTier({
    required this.minAmount,
    this.maxAmount,
    required this.incentiveAmount,
  });

  final num minAmount;
  final num? maxAmount;
  final num incentiveAmount;

  Map<String, dynamic> toJson() {
    return {
      'minAmount': minAmount,
      'maxAmount': maxAmount ?? 0,
      'incentiveAmount': incentiveAmount,
    };
  }
}

class OrganizationSetupInvite {
  const OrganizationSetupInvite({
    required this.email,
    required this.roleId,
    this.roleName,
  });

  final String email;
  final String roleId;
  final String? roleName;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'role': roleId,
    };
  }
}
