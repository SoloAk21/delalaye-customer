import 'package:delalochu/presentation/map_view/model/broker_info_model.dart';
import 'package:flutter/material.dart';

class BrokerCard extends StatelessWidget {
  final BrokerInfo broker;

  const BrokerCard({Key? key, required this.broker}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundImage: NetworkImage(broker.photo ?? '')),
      title: Text(broker.fullName ?? 'Unknown'),
      subtitle: Text(broker.phone ?? 'No contact'),
      trailing: const Icon(Icons.directions_car, color: Colors.green),
    );
  }
}
