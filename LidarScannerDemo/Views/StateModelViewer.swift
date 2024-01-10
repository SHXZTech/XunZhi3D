import SwiftUI
import SceneKit

@available(iOS 16.4, *)
struct StateModelViewer: View {
    @Binding var modelURL: URL?
    

    var width = UIScreen.main.bounds.width
    var height = UIScreen.main.bounds.height
    
    @State var showMeasureSheet = false
    @State var measuredDistance = 0.0
    @State var isMeasuredFirstPoint = false
    @State var isReturnToInit = false
    
    @State private var viewKey = UUID()
    var body: some View {
        ZStack {
            if let url = modelURL {
                ObjModelMeasureView(objURL: url, isMeasureActive: $showMeasureSheet, measuredDistance: $measuredDistance, isMeasuredFirstPoint: $isMeasuredFirstPoint, isReturnToInit: $isReturnToInit)
                    .frame(width: width, height: height)
                    .id(viewKey)  // Use the key here
            } else {
                Text(NSLocalizedString("No model to display", comment: ""))
            }
            ToolBarView()
        }
        .onChange(of: modelURL) { _ in
            viewKey = UUID()  // Change the key to force a refresh
        }
        .sheet(isPresented: $showMeasureSheet) {
            MeasureSheetView(isPresented: $showMeasureSheet, measuredDistance: $measuredDistance, isMeasuredFirstPoint: $isMeasuredFirstPoint, isReturnToInit: $isReturnToInit) // Your custom bottom sheet view
                .presentationDetents([
                    .height(130),   // 100 points
                ])
                .presentationCornerRadius(0)
                .presentationBackgroundInteraction(.enabled(upThrough: .height(130)))
        }
    }
    
   
    
    
    private func ToolBarView() -> some View{
        VStack{
            Spacer()
            HStack(){
                Spacer()
                measureButtonView()
                Spacer()
                pipelineButtonView()
                Spacer()
            }
            .padding(.bottom,20)
        }
    }
    
    private func measureButtonView() -> some View {
        VStack {
            Button(action: {
                showMeasureSheet.toggle()
            }) {
                Image(systemName: "ruler")
                    .font(.title)
                    .frame(width: 50, height: 50)
                    .background(Circle().fill(Color.black.opacity(0.4)))
                    .foregroundColor(.white)
            }
            Text(NSLocalizedString("Measure", comment: "measure"))
                .foregroundColor(.black)
                .font(.footnote)
        }
        .padding(.bottom, 10)
    }
    private func pipelineButtonView() -> some View {
        VStack {
            Button(action: {
                showMeasureSheet.toggle()
            }) {
                Image(systemName: "skew") // or 􁤓
                    .font(.title)
                    .frame(width: 50, height: 50)
                    .background(Circle().fill(Color.black.opacity(0.4)))
                    .foregroundColor(.white)
            }
            Text(NSLocalizedString("Pipeline", comment: "measure"))
                .foregroundColor(.black)
                .font(.footnote)
        }
        .padding(.bottom, 10)
    }
    
    
}

