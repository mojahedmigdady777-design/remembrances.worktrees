class Student {
  String name;

  String supervisor;

  String halaqa;

  Student({
    required this.name,
    required this.supervisor,
    required this.halaqa,
  });

  factory Student.empty() {
    return Student(
      name: "",
      supervisor: "",
      halaqa: "",
    );
  }
}