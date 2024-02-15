
import SwiftUI


public struct PagedCalendar<Content: View>: View {
  
  @State private var calendarPeriods = CalendarPeriods()
  @State private var intervalSelection: IntervalSelection = .day
  @State private var positionId: Int?
  
  let navTitle: String
  
  let content: (any CalendarModel) -> Content
  
  public init(navigationTitle: String = "", @ViewBuilder content: @escaping (any CalendarModel) -> Content) {
    
    self.navTitle = navigationTitle
    self.content = content
  }

  public var body: some View {
    
    GeometryReader { geo in
      
      
      VStack {
        
        segmentControl
        
        periodView
      }
      .navigationTitle(navTitle)
      .padding()
      .animation(.easeInOut, value: intervalSelection)
      .onChange(of: positionId, loadMoreIfNeeded)
    }
  }
  
  
  @ViewBuilder
  private var periodView: some View {
    
    switch intervalSelection {
    case .day:
      PeriodView(periods: $calendarPeriods.dayModel, positionId: $positionId, content: descriptionOf)
    case .week:
      PeriodView(periods: $calendarPeriods.weekModel, positionId: $positionId, content: descriptionOf)
    case .month:
      PeriodView(periods: $calendarPeriods.monthModel, positionId: $positionId, content: descriptionOf)
    case .year:
      PeriodView(periods: $calendarPeriods.yearModel, positionId: $positionId, content: descriptionOf)
    }
  }
  
  @ViewBuilder
  private func descriptionOf<T: CalendarModel>(_ period: T) -> some View {
    
    VStack {
      
      Text(period.startDate.description)
      Text(period.endDate.description)
      
      content(period as! (any CalendarModel))
    }
  }
  
  @ViewBuilder
  private var segmentControl: some View {
    
    Picker("Calendar Selection", selection: $intervalSelection) {
      ForEach(IntervalSelection.allCases, id: \.self) { selection in
        Text(selection.rawValue).tag(selection)
      }
    }
    .pickerStyle(.segmented)
  }
  
  private func loadMoreIfNeeded() {
    
    switch intervalSelection {
    case .day:
      loadMoreIfNeeded(for: &calendarPeriods.dayModel)
    case .week:
      loadMoreIfNeeded(for: &calendarPeriods.weekModel)
    case .month:
      loadMoreIfNeeded(for: &calendarPeriods.monthModel)
    case .year:
      loadMoreIfNeeded(for: &calendarPeriods.yearModel)
    }

  }
  
  private func loadMoreIfNeeded<T>(for items: inout [T]) where T: Identifiable & CalendarModel {
    
    if let positionId = positionId, positionId == items.count - 1 {
      
      
      let newItems = [
        T.init(minus: positionId + 1),
        T.init(minus: positionId + 2)
      ]
      
      items.append(contentsOf: newItems)
    }
  }
}

