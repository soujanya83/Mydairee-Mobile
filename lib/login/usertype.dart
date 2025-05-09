import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/login/adminlogin.dart';
import 'package:mykronicle_mobile/login/parentlogin.dart';
import 'package:mykronicle_mobile/login/stafflogin.dart';
import 'package:mykronicle_mobile/services/constants.dart';

class UserType extends StatefulWidget {
  static String Tag = Constants.USER_TYPE_TAG;

  @override
  _UserTypeState createState() => _UserTypeState();
}

class _UserTypeState extends State<UserType> {
  String? _selectedRole; // Tracks which role is selected
  bool _showNextButton = false; // Controls Next button visibility

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.15),
            Text(
              "Welcome!",
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Select User Type",
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 32),

            // Admin Option
            _buildSelectableOption(
              "Admin",
              Constants.ADMIN_LOGO,
              _selectedRole == "Admin",
              () => _handleRoleSelection("Admin"),
            ),

            // Staff Option
            _buildSelectableOption(
              "Staff",
              Constants.STAFF_LOGO,
              _selectedRole == "Staff",
              () => _handleRoleSelection("Staff"),
            ),

            // Parent Option
            _buildSelectableOption(
              "Parent",
              Constants.PARENT_LOGO,
              _selectedRole == "Parent",
              () => _handleRoleSelection("Parent"),
            ),

            Spacer(),

            // Next Button (conditionally visible)
            if (_showNextButton)
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: SizedBox(
                    width: double.infinity,
                    child: // Replace ElevatedButton with this code
                        Container(
                      decoration: BoxDecoration(
                        color: _selectedRole != null
                            ? Constants.kButton
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: _selectedRole != null
                              ? Constants.kButton.withOpacity(0.3)
                              : Colors.grey.shade200,
                          width: 1.5,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(200),
                          onTap: _selectedRole != null
                              ? _navigateBasedOnSelection
                              : null,
                          splashColor: Colors.white.withOpacity(0.2),
                          highlightColor: Colors.white.withOpacity(0.1),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Text(
                              "Next",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )),
              ),
          ],
        ),
      ),
    );
  }

  void _handleRoleSelection(String role) {
    setState(() {
      _selectedRole = role;
      _showNextButton = true; // Show Next button when a role is selected
    });
  }

  void _navigateBasedOnSelection() {
    switch (_selectedRole) {
      case "Admin":
        Navigator.of(context).pushNamed(AdminLogin.Tag);
        break;
      case "Staff":
        Navigator.of(context).pushNamed(StaffLogin.Tag);
        break;
      case "Parent":
        Navigator.of(context).pushNamed(ParentLogin.Tag);
        break;
    }
  }

  Widget _buildSelectableOption(
      String role, String iconPath, bool isSelected, VoidCallback onTap) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isSelected ? 0.08 : 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isSelected ? Colors.blue.shade300 : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(200),
          onTap: onTap,
          splashColor: Colors.blue.withOpacity(0.1),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(width: 10),

                // Role icon with subtle background
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: EdgeInsets.all(10),
                  child: ColorFiltered(
                    colorFilter: isSelected
                        ? ColorFilter.mode(
                            Colors.blue.shade600, BlendMode.srcIn)
                        : ColorFilter.mode(
                            Colors.grey.shade700, BlendMode.srcIn),
                    child: Image.asset(iconPath),
                  ),
                ),
                SizedBox(width: 16),

                // Role text
                Expanded(
                  child: Text(
                    role,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.blue.shade800
                          : Colors.grey.shade800,
                    ),
                  ),
                ),

                // Chevron icon
                // Selection indicator with animation
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? Colors.blue : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
