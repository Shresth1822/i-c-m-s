import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/claim.dart';
import '../../domain/entities/claim_status.dart';
import '../providers/claim_provider.dart';

class ClaimFormScreen extends ConsumerStatefulWidget {
  final Claim? claim;

  const ClaimFormScreen({super.key, this.claim});

  @override
  ConsumerState<ClaimFormScreen> createState() => _ClaimFormScreenState();
}

class _ClaimFormScreenState extends ConsumerState<ClaimFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _policyNumberController;
  late TextEditingController _patientNameController;
  late TextEditingController _patientEmailController;
  late ClaimStatus _selectedStatus;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final claim = widget.claim;
    _policyNumberController = TextEditingController(
      text: claim?.policyNumber ?? '',
    );
    _patientNameController = TextEditingController(
      text: claim?.patientName ?? '',
    );
    _patientEmailController = TextEditingController(
      text: claim?.patientEmail ?? '',
    );
    _selectedStatus = claim?.status ?? ClaimStatus.draft;
  }

  @override
  void dispose() {
    _policyNumberController.dispose();
    _patientNameController.dispose();
    _patientEmailController.dispose();
    super.dispose();
  }

  Future<void> _saveClaim() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final isEditing = widget.claim != null;
      final now = DateTime.now();

      final newClaim = Claim(
        id: widget.claim?.id ?? '', // ID handled by Repo/DB if empty
        policyNumber: _policyNumberController.text.trim(),
        patientName: _patientNameController.text.trim(),
        patientEmail: _patientEmailController.text.trim().isEmpty
            ? null
            : _patientEmailController.text.trim(),
        status: _selectedStatus,
        createdAt: widget.claim?.createdAt ?? now,
        updatedAt: now,
        bills: widget.claim?.bills ?? [],
        advances: widget.claim?.advances ?? [],
        settlements: widget.claim?.settlements ?? [],
      );

      if (isEditing) {
        await ref.read(claimsProvider.notifier).updateClaim(newClaim);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Claim updated successfully')),
          );
        }
      } else {
        await ref.read(claimsProvider.notifier).addClaim(newClaim);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Claim created successfully')),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving claim: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.claim != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Claim' : 'New Claim')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Policy Number
              TextFormField(
                controller: _policyNumberController,
                decoration: const InputDecoration(
                  labelText: 'Policy Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter policy number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Patient Name
              TextFormField(
                controller: _patientNameController,
                decoration: const InputDecoration(
                  labelText: 'Patient Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter patient name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Patient Email
              TextFormField(
                controller: _patientEmailController,
                decoration: const InputDecoration(
                  labelText: 'Patient Email (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    // Simple email regex
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              if (isEditing) ...[
                // Status (Read-Only)
                TextFormField(
                  initialValue: _selectedStatus.label,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.info_outline),
                    enabled: false, // Make it read-only
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Save Button
              FilledButton.icon(
                onPressed: _isSaving ? null : _saveClaim,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _isSaving
                      ? 'Saving...'
                      : (isEditing ? 'Update Claim' : 'Create Claim'),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
