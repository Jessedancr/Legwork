import 'package:flutter/material.dart';
import 'package:legwork/Features/auth/presentation/Widgets/auth_button.dart';
import 'package:legwork/Features/auth/presentation/Widgets/auth_text_form_field.dart';
import 'package:legwork/Features/auth/presentation/Widgets/large_textfield.dart';

// TEXTFORMFIELD KEY
final formKey = GlobalKey<FormState>();

class WorkExperienceBottomSheet extends StatefulWidget {
  final void Function()? onPressed;
  final TextEditingController titleController;
  final TextEditingController employerController;
  final TextEditingController locationController;
  final TextEditingController jobDescrController;
  final TextEditingController dateController;
  final dynamic Function()? showDatePicker;
  const WorkExperienceBottomSheet({
    super.key,
    required this.onPressed,
    required this.employerController,
    required this.jobDescrController,
    required this.locationController,
    required this.titleController,
    required this.dateController,
    required this.showDatePicker,
  });

  @override
  State<WorkExperienceBottomSheet> createState() =>
      _WorkExperienceBottomSheetState();
}

class _WorkExperienceBottomSheetState extends State<WorkExperienceBottomSheet> {
  // BUILD METHOD
  @override
  Widget build(BuildContext context) {
    // SCREEN SIZE
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // RETURNED WIDGET
    return SingleChildScrollView(
      child: Container(
        height: screenHeight,
        decoration: BoxDecoration(
          //color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
            vertical: 10,
          ),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                // Job Title text field
                AuthTextFormField(
                  hintText: 'Title',
                  obscureText: false,
                  controller: widget.titleController,
                  icon: Image.asset('images/icons/title.png'),
                  helperText: 'Ex: back up dancer',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please fill in your job role/title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Employer text field
                AuthTextFormField(
                  hintText: 'Employer',
                  obscureText: false,
                  controller: widget.employerController,
                  icon: Image.asset('images/icons/employer.png'),
                  helperText: 'Ex: TMG',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please fill in your employer, abi pesin no employ you to do work??';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Location textfield
                AuthTextFormField(
                  hintText: 'Location',
                  obscureText: false,
                  controller: widget.locationController,
                  icon: Image.asset(
                    'images/icons/location.png',
                    //height: 2,
                  ),
                  helperText: 'Ex: Lekki phase 1',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please fill in location abi the work wey you do no get location??';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                AuthTextFormField(
                  hintText: 'date',
                  obscureText: false,
                  controller: widget.dateController,
                  icon: const Icon(Icons.date_range),
                  onTap: widget.showDatePicker,
                ),
                const SizedBox(height: 20),

                LargeTextField(
                  hintText: 'Job description',
                  obscureText: false,
                  controller: widget.jobDescrController,
                  icon: const Icon(Icons.description),
                ),

                AuthButton(
                  onPressed: widget.onPressed,
                  buttonText: 'Save',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
