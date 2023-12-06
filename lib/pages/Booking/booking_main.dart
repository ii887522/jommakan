import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:jom_makan/pages/Booking/qr_display.dart';
import 'package:jom_makan/server/seat_display/seat_display.dart';
import 'package:book_my_seat/book_my_seat.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jom_makan/stores/seatlist_provider.dart';
import 'package:provider/provider.dart';

/* void main() {
  runApp(const BookSeatPage());
}

class BookSeatPage extends StatelessWidget {
  const BookSeatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'book_my_seat package example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BusLayout(),
    );
  }
} */

class BusLayout extends StatefulWidget {
  final ValueNotifier<String> selectedSeatsNotifier;
  const BusLayout({super.key, required this.selectedSeatsNotifier});

  @override
  State<StatefulWidget> createState() => _BusLayoutState();
}

class _BusLayoutState extends State<BusLayout> {
  Set<SeatNumber> selectedSeats = {};
  Uint8List? qrCodeBytes; // Use Uint8List to store image bytes
  final SeatDisplay addSeat = SeatDisplay();
  
  final TextEditingController _rowController = TextEditingController();
  var itemData = [];

  Future<void> generateQRCode(Set<SeatNumber> selectedSeats) async {
    final List<Map<String, Object>> seatsList = selectedSeats
    .map((seat) => {
          'text': 'Welcome To JomMakan Seating',
          // 'textStyle': TextStyle(fontWeight: FontWeight.bold),
          'rowI': seat.rowI,
          'colI': seat.colI,
        })
    .toList();

    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/generate_qr'),
      // Uri.parse('http://your-flask-server-ip:5000/generate_qr'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'data': seatsList,
      }),
    );
    print(seatsList.map((seat) => seat['rowI']).toList());

    if (response.statusCode == 200) {
      final File file = File('assets/example.png');
      await file.writeAsBytes(response.bodyBytes);

      setState(() {
        qrCodeBytes = response.bodyBytes;
      });

      // Navigate to a new page to display the QR code
      goToQrDisplayPage(selectedSeats);
    } else {
      // Handle errors
      print('Failed to generate QR code: ${response.statusCode}');
    }
  }

  void goToQrDisplayPage(Set<SeatNumber> selectedSeats) {
    Navigator.push(
      context, MaterialPageRoute(
        builder: (context) => QRCodeDisplayPage(
          qrCodeBytes: qrCodeBytes!,
          selectedSeats: selectedSeats,
          selectedSeatsNotifier: widget.selectedSeatsNotifier,
        ),
      ),
    ).then((selectedSeats) {
      Navigator.pop(context, selectedSeats);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            const Text("Please Select Your Seat"),
            const SizedBox(height: 32),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: double.maxFinite,
                height: 500,
                child: SeatLayoutWidget(
                  onSeatStateChanged: (rowI, colI, seatState) {
                    if (seatState == SeatState.selected) {
                      selectedSeats.add(SeatNumber(rowI: rowI, colI: colI));
                    } else {
                      selectedSeats.remove(SeatNumber(rowI: rowI, colI: colI));
                    }
                    setState(() {}); // Trigger a rebuild when seats are selected/deselected
                  },
                  stateModel: const SeatLayoutStateModel(
                    rows: 10,
                    cols: 7,
                    seatSvgSize: 45,
                    pathSelectedSeat: 'assets/seat_selected.svg',
                    pathDisabledSeat: 'assets/seat_disabled.svg',
                    pathSoldSeat: 'assets/seat_sold.svg',
                    pathUnSelectedSeat: 'assets/seat_unselected.svg',
                    currentSeatsState: [
                      [
                        SeatState.disabled,
                        SeatState.unselected,
                        SeatState.unselected,
                        SeatState.empty,
                        SeatState.unselected,
                        SeatState.unselected,
                        SeatState.sold,
                      ],
                      [
                        SeatState.unselected,
                        SeatState.unselected,
                        SeatState.unselected,
                        SeatState.empty,
                        SeatState.unselected,
                        SeatState.unselected,
                        SeatState.unselected,
                      ],
                      [
                        SeatState.unselected,
                        SeatState.unselected,
                        SeatState.unselected,
                        SeatState.empty,
                        SeatState.sold,
                        SeatState.sold,
                        SeatState.sold,
                      ],
                      [
                        SeatState.unselected,
                        SeatState.unselected,
                        SeatState.unselected,
                        SeatState.empty,
                        SeatState.unselected,
                        SeatState.unselected,
                        SeatState.unselected,
                      ],
                      [
                        SeatState.unselected,
                        SeatState.unselected,
                        SeatState.unselected,
                        SeatState.empty,
                        SeatState.unselected,
                        SeatState.sold,
                        SeatState.sold,
                      ],
                      [
                        SeatState.sold,
                        SeatState.unselected,
                        SeatState.unselected,
                        SeatState.empty,
                        SeatState.unselected,
                        SeatState.unselected,
                        SeatState.unselected,
                      ],
                      [
                        SeatState.unselected,
                        SeatState.unselected,
                        SeatState.unselected,
                        SeatState.empty,
                        SeatState.unselected,
                        SeatState.unselected,
                        SeatState.unselected,
                      ],
                      [
                        SeatState.sold,
                        SeatState.sold,
                        SeatState.unselected,
                        SeatState.empty,
                        SeatState.unselected,
                        SeatState.unselected,
                        SeatState.unselected,
                      ],
                      [
                        SeatState.empty,
                        SeatState.empty,
                        SeatState.empty,
                        SeatState.empty,
                        SeatState.unselected,
                        SeatState.unselected,
                        SeatState.sold,
                      ],
                      [
                        SeatState.unselected,
                        SeatState.unselected,
                        SeatState.sold,
                        SeatState.sold,
                        SeatState.sold,
                        SeatState.unselected,
                        SeatState.unselected,
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 15,
                        height: 15,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 2),
                      const Text('Disabled')
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 15,
                        height: 15,
                        color: Colors.lightBlueAccent,
                      ),
                      const SizedBox(width: 2),
                      const Text('Sold')
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(border: Border.all(color: const Color(0xff0FFF50))),
                      ),
                      const SizedBox(width: 2),
                      const Text('Available')
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 15,
                        height: 15,
                        color: const Color(0xff0FFF50),
                      ),
                      const SizedBox(width: 2),
                      const Text('Selected by you')
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 12),
            Text(selectedSeats.join(" , ")), // Display selected seat numbers directly
            const SizedBox(height: 12),
            // Add a button to generate the QR code
            ElevatedButton(
              onPressed: () => showSeatConfirmation(),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) => const Color(0xFFfc4c4e)),
              ),
              child: const Text('Generate QR Code'),
            ),
            const SizedBox(height: 20),
            // Display the QR code using QrImage
            if (qrCodeBytes != null)
              Image.memory(
                qrCodeBytes!,
                width: 200.0,
                height: 200.0,
              ),
              Column(
                children: [
                  TextField(
                    controller: _rowController,
                    onTap: () {
                      setState(() {
                        selectedSeats.map((seat) => '${seat.rowI}').join(' ');
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showSeatConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation?'),
          content: Text('Are you sure you want to book the following seat(s): $selectedSeats'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Yes'),
              onPressed: () async {
                Navigator.of(context).pop();

                generateQRCode(selectedSeats);
                seatAdded();
              },
            ),
          ],
        );
      }
    );
  }

  // Passing the data to "server/register.dart" for performing the server-side script
  void seatAdded() {
    // Generate a unique confirmationID (starting from C0001)
    String confirmationID =
      'C${DateTime.now().millisecondsSinceEpoch % 10000}'.padLeft(5, '0');

    // Assume that location is always "RedBrick Cafe"
    String location = 'RedBrick Cafe';

    // Get the current date and time
    DateTime now = DateTime.now();

    List<Map<String, dynamic>> seatsList = [];

    // TODO: don't call the add seat to database function yet, put in place order function
    for (SeatNumber seat in selectedSeats) {
      int row = seat.rowI;
      int col = seat.colI;

      Map<String, dynamic> seatData = {
        'confirmationID': confirmationID,
        'row': row,
        'col': col,
        'location': location,
        'time': now,
      };

      seatsList.add(seatData);

      // TODO: Call this function will add the seat data to the database
      /* bool registrationResult = await addSeat.seatAdded(
        confirmationID: confirmationID,
        row: row,
        col: col,
        location: location,
        time: now,
      );

      if (registrationResult) {
        // Seat added successfully, you can perform any additional actions here
        print('Seat added successfully: $seat');
      } else {
        // Handle the case when the seat addition fails
        print('Failed to add seat: $seat');
      } */
    }

    // Store the selected seat details to the provider
    Provider.of<SeatListProvider>(context, listen: false).setSeatList(seatsList);
  }
}

class UIPage extends StatelessWidget {
  final String logoUrl;
  final String welcomeText;

  const UIPage({
    required this.logoUrl,
    required this.welcomeText,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UI Display Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              logoUrl,
              width: 100.0,
              height: 100.0,
            ),
            const SizedBox(height: 20),
            Text(
              welcomeText,
              style: const TextStyle(fontSize: 20.0),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectedSeatsNotifier extends ValueNotifier<List<String>> {
  SelectedSeatsNotifier() : super([]);

  void updateSeats(List<String> newSeats) {
    value = newSeats;
  }
}