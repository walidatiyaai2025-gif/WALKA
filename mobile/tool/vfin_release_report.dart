import 'src/vfin_release_snapshot.dart';

void main(List<String> args) {
  final String provenancePath = args.isEmpty
      ? '../docs/ui/PRODUCTION_ASSET_PROVENANCE.json'
      : args.first;
  final VfinReleaseSnapshot snapshot = vfinSnapshotFromFile(provenancePath);
  print(vfinStableJson(snapshot));
}
