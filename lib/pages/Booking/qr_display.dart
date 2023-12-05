import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:jom_makan/components/logo.dart';
import 'package:jom_makan/server/seatDisplay/seatDisplay.dart';
import 'package:photo_view/photo_view.dart';

class QRCodeDisplayPage extends StatefulWidget {
  final Uint8List qrCodeBytes;
  final Set<SeatNumber> selectedSeats;

  const QRCodeDisplayPage({super.key, required this.qrCodeBytes, required this.selectedSeats});

  @override
  State<StatefulWidget> createState() => _QRCodeDisplayPageState();
}

class _QRCodeDisplayPageState extends State<QRCodeDisplayPage> {
  final Logo _logo = Logo();
  final SeatDisplay addSeat = SeatDisplay();
  List<Map<String, dynamic>> _addSeat = [];

  var itemData = [];

  @override
  void initState() {
    super.initState();
    _getSeatData();
  }

  void _getSeatData() async {
    List<Map<String, dynamic>> selectedData = [];
    try {
      // data means getting all seats
      // need to do something with the selected Seats
      final data = await addSeat.getSeatingData();

      // Loop through each selected set
      for (final selectedSeat in widget.selectedSeats) {
        // Find the corresponding seat detail from the data list using the selectedSeat row and col
        Map<String, dynamic>? selectedSeatDetail;
        for (final seat in data) {
          if (int.parse(seat['row']) == selectedSeat.rowI && int.parse(seat['col']) == selectedSeat.colI) {
            selectedSeatDetail = seat;
            print('Selected seat detail: $selectedSeatDetail');
            break;
          }
        }

        // If a matching seat detail is found, add it to the selectedData list
        if (selectedSeatDetail != null) {
          selectedData.add(selectedSeatDetail);
        }
      }

      if (mounted) {
        setState(() {
          _addSeat = selectedData;
        });
      }
      //print('Selected Seat: ${widget.selectedSeats}');
      //print('Add Seat: $_addSeat');
    } catch (e) {
      print('Error loading seat data: $e');
    }
  }

  // Function to get seat status
  Future<String> getSeatStatus(SeatNumber seat) async {
    // Use your logic to get the current status of the seat
    // For example, you can use the _addSeat list to get the status
    for (var seatData in _addSeat) {
      if (seatData['row'] == seat.rowI && seatData['col'] == seat.colI) {
        return seatData['status'] ?? 'Unknown';
      }
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('QR Code Display', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Thanks You To Choosing JomMakan',
              style: TextStyle(fontSize: 15),
            ),
            _loadQrCode(),
            _loadSeatDetails(),
            const SizedBox(height: 10),
            Text(
              'Selected Seats: ${widget.selectedSeats.join(", ")}',
              style: const TextStyle(fontSize: 14.0),
            ),
            const SizedBox(height: 10),
            _loadSeatStatus(),
            const SizedBox(height: 10),
            const Text(
              'Location: Red Bricks Cafe',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8.0),
          _logo.getLogoWithTarumt(),
          const SizedBox(height: 8.0),
        ],
      ),
    );
  }

  Widget _loadQrCode() {
    return SizedBox(
      height: 200,
      width: 200,
      child: PhotoView(
        imageProvider: MemoryImage(widget.qrCodeBytes),
        minScale: PhotoViewComputedScale.contained * 0.8,
        maxScale: PhotoViewComputedScale.covered * 2,
        backgroundDecoration: const BoxDecoration(color: Colors.white),
      ),
    );
  }

  Widget _loadSeatDetails() {
    // Display the selected seat details using a PageView
    return SizedBox(
      height: 150,
      child: PageView.builder(
        itemCount: _addSeat.length,
        itemBuilder: (context, index) {
          final seatDetail = _addSeat[index];
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Seat Details',
                  style: TextStyle(fontSize: 13),
                ),
                Text(
                  'Confirmation ID: ${seatDetail['confirmationID']}',
                  style: const TextStyle(fontSize: 13),
                ),
                Text(
                  'Row: ${seatDetail['row']}',
                  style: const TextStyle(fontSize: 13),
                ),
                Text(
                  'Col: ${seatDetail['col']}',
                  style: const TextStyle(fontSize: 13),
                ),
                Text(
                  'Location: ${seatDetail['location']}',
                  style: const TextStyle(fontSize: 13),
                ),
                Text(
                  'Time: ${seatDetail['time']}',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _loadSeatStatus() {
    return Column(
      children: widget.selectedSeats.map((seat) {
        return FutureBuilder<String>(
          future: getSeatStatus(seat),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('Error loading seat status');
            } else {
              String seatStatus = snapshot.data ?? 'Available';
              return Text(
                'Seat ${seat.rowI}-${seat.colI}: $seatStatus',
                style: const TextStyle(fontSize: 18.0),
              );
            }
          },
        );
      }).toList(),
    );
  }
}

class SeatNumber {
  final int rowI;
  final int colI;

  const SeatNumber({required this.rowI, required this.colI});

  @override
  bool operator == (Object other) {
    return rowI == (other as SeatNumber).rowI && colI == other.colI;
  }

  @override
  int get hashCode => rowI.hashCode;

  @override
  String toString() {
    return '[$rowI][$colI]';
  }
}