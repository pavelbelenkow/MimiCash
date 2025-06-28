struct CSV {
    typealias Header = String
    typealias Value = String

    let rows: [[Header: Value]]
}
