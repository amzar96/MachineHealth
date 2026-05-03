protocol MachineProvider {
    var specs: MachineSpecs { get }
    func fetchHealthSnapshot() -> HealthSnapshot
}
