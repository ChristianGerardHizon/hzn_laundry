/// First-branch payload collected by the create-organization setup wizard.
class OrganizationSetupBranch {
  const OrganizationSetupBranch({
    required this.name,
    required this.address,
    required this.contactNumber,
    this.operatingHours,
    this.cutOffTime,
  });

  final String name;
  final String address;
  final String contactNumber;
  final String? operatingHours;
  final String? cutOffTime;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'contactNumber': contactNumber,
      'operatingHours': operatingHours ?? '',
      'cutOffTime': cutOffTime ?? '',
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
