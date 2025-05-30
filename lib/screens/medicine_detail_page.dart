import 'package:flutter/material.dart';

import '../models/medicine.dart'; // Added dart:io for File

class MedicineDetailPage extends StatelessWidget {

  final Medicine medicine;
  const MedicineDetailPage({Key? key, required this.medicine}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Retrieve the Medicine object passed as arguments.

    Widget imageWidget;
    // Check if imagePath is not null and not empty
    if (medicine.imagePath.isNotEmpty) {
      // Assuming imagePath is an asset path for now
      // If using File or Network image, you'll need the appropriate widget and imports
      imageWidget = Image.asset(medicine.imagePath); // Use medicine.imagePath!
    } else {
      // Placeholder image: ensure assets/images/pill_placeholder.png exists
      // and is listed in pubspec.yaml under assets.
      imageWidget = Image.asset('assets/images/pill_placeholder.png'); // Changed to placeholder
    }

    final detailsWidget = SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Name',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4.0),
          Text(
            medicine.name,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16.0),
          Text(
            'Strength',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4.0),
          Text(
            medicine.strength,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16.0),
          Text(
            'Quantity',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4.0),
          Text(
            medicine.quantity.toString(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16.0),
          Text(
            'Expiry Date',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4.0),
          Text(
            medicine.expiry.toLocal().toString().split(' ')[0],
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          // Add other medicine details here as needed
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(medicine.name), // App bar title could be the medicine name
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 700) {
            // Two-column layout for wider screens
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Hero(
                        tag: 'medicineImage_${medicine.id}', // Unique tag for Hero animation
                        child: imageWidget,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: detailsWidget,
                ),
              ],
            );
          } else {
            // Single-column layout for narrower screens
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Hero(
                     tag: 'medicineImage_${medicine.id}', // Unique tag for Hero animation
                    child: imageWidget,
                  ),
                ),
                Expanded(
                  child: detailsWidget,
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement "Add Reminder" functionality
          print('Add Reminder button pressed');
        },
        label: const Text('Add Reminder'),
        icon: const Icon(Icons.alarm_add),
      ),
    );
  }
}