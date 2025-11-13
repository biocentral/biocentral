class SetGeneratedEvent {
  final String columnName;

  SetGeneratedEvent({required this.columnName});
}

class BiotrainerStartTrainingEvent {
  final Type databaseType;
  final Map<String, String> trainingConfiguration;

  BiotrainerStartTrainingEvent({required this.databaseType, required this.trainingConfiguration});
}
