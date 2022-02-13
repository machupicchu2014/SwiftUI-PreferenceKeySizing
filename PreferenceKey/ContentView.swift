import SwiftUI

// MARK: - Preference Keys
// Stores the largest height so far for each row of each column
struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]
    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        let rowHeightDict = nextValue()
        for row in rowHeightDict.keys where rowHeightDict[row] != nil {
            if value[row] == nil {
                value[row] = rowHeightDict[row]
            } else {
                value[row] = rowHeightDict[row]! > value[row]! ? rowHeightDict[row] : value[row]
            }
        }
        
    }
}

// MARK: - Top Level View, multiple columns in an HStack
struct MultiColumnView: View {
    class HeightModel: ObservableObject {
        @Published var rowHeights: [Int: CGFloat] = [:]
        
        func height(for row: Int) -> CGFloat? {
            return rowHeights[row]
        }
    }
    
    @ObservedObject private var heightModel = HeightModel()
    @State var columns: [[String]]
    
    var body: some View {
        ScrollView {
            HStack {
                ForEach(columns, id: \.forEachIdentifier) { column in
                    ColumnView(titles: column)
                }
            }
        }.onPreferenceChange(HeightPreferenceKey.self) { newHeights in
            heightModel.rowHeights = newHeights
        }.environmentObject(heightModel)
    }
}

struct RowView_Previews: PreviewProvider {
    // You can freely add new columns here...this will adapt fine
    static let columns: [[String]] = [
        ["Hello", "Longer title that is easy to forget", "This is an extremely long string just to see how this does now okay??", "Spider"],
        ["Longer title", "Hello", "Fish", "This is a long string just to see how this does now okay??"],
        ["A", "B", "C", "D"]
    ]
    
    static var previews: some View {
        return MultiColumnView(columns: columns)
    }
}

// MARK: - View for single column
struct ColumnView: View {
    @State var titles: [String]
    
    // We get this from the parent view...it has the most current height found for each row
    @EnvironmentObject var heightModel: MultiColumnView.HeightModel

    var body: some View {
        VStack {
            ForEach(Array(titles.enumerated()), id: \.element) { (index, element) in
                LabeledTextInput(label: element, rowIndex: index)
                    .frame(minHeight: heightModel.height(for: index), maxHeight: heightModel.height(for: index))
                    .background(randomColor)
            }
        }
    }
    
    var randomColor: Color {
        let randomUIColor = UIColor(displayP3Red: CGFloat.random(in: 0..<1), green: CGFloat.random(in: 0..<1), blue: CGFloat.random(in: 0..<1), alpha: CGFloat.random(in: 0..<1))
        return Color(uiColor: randomUIColor)
    }
}

// MARK: - Label+TextField view
struct LabeledTextInput: View {
    var label: String
    let rowIndex: Int
    @State var textFieldText: String = ""
    
    var body: some View {
        VStack {
            Text(label)
                .frame(maxWidth: .infinity)
            TextField("0", text: $textFieldText)
                .textFieldStyle(.roundedBorder)
        }
            .background(
                // This GeometryReader in the background measures the current size of this view and informs the height preferences of this size so it can update to the new height if larger than the previous height found for the row
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: HeightPreferenceKey.self, value: [rowIndex: proxy.size.height])
                }
            )
    }
}


// MARK: - Extensions
extension Array where Element == String {
    var forEachIdentifier: String {
        return self.joined(separator: ",")
    }
}
