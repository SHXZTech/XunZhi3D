import SwiftUI
import SceneKit

struct StateModelViewer: View {
    
    @Binding var modelURL: URL?
    @Binding var isModelViewerTop: Bool

    var uuid: UUID
    var width = UIScreen.main.bounds.width
    var height = UIScreen.main.bounds.height
    
    @State var showPointMeasureSheet = false
    @State var point_x = 0.0;
    @State var point_y = 0.0
    @State var point_z = 0.0;
    
    @State var showMeasureSheet = false
    @State var measuredDistance = 0.0
    @State var isMeasuredFirstPoint = false
    @State var isReturnToInit = false
    
    @State var showPipelineSheet = false
    @State var isPipelineDrawFirstPoint = false
    @State var isPipelineReturnOneStep = false
    @State var pipelineExportedImage:Image?
    @State var isExportImage = false
    @State var isExportCAD = false
    @State var CAD_url: URL?
    
    @State var isModelLoading = true;
    
    
    @State private var viewKey = UUID()
    var body: some View {
        ZStack {
            if let url = modelURL {
                ObjModelMeasureView(objURL: url, isPointMeasureActive: $showPointMeasureSheet, point_x: $point_x, point_y: $point_y, point_z: $point_z, isMeasureActive: $showMeasureSheet, measuredDistance: $measuredDistance, isMeasuredFirstPoint: $isMeasuredFirstPoint, isReturnToInit: $isReturnToInit, isPipelineActive: $showPipelineSheet, isPipelineDrawFirstPoint: $isPipelineDrawFirstPoint, isPipelineReturnOneStep: $isPipelineReturnOneStep, isExportImage: $isExportImage, exportedImage: $pipelineExportedImage, isModelLoading: $isModelLoading, isExportCAD: $isExportCAD, exported_CAD_url: $CAD_url)
                    .frame(width: width, height: height)
                    .id(viewKey)  // Use the key here
            } else {
                Text(NSLocalizedString("No model to display", comment: ""))
            }
            ToolBarView()
            if isModelLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                    .foregroundColor(.mint)
                    .scaleEffect(1)
            }
        }
        .onChange(of: modelURL) { _ in
            viewKey = UUID()  // Change the key to force a refresh
        }
        .onChange(of: isModelViewerTop) { newValue in
            if newValue == false {
                showPipelineSheet = false
                showMeasureSheet = false
                showPointMeasureSheet = false
            }
        }
        .sheet(isPresented: $showPointMeasureSheet) {
            PointMeasureSheetView(isPresented: $showPointMeasureSheet, point_x: $point_x, point_y: $point_y, point_z: $point_z, uuid: self.uuid)
                .presentationDetents([
                    .height(150),   // 100 points //why set 150 here, whill toggle
                ])
                .presentationCornerRadius(0)
                .presentationBackgroundInteraction(.enabled(upThrough: .height(150)))
            
        }
        .sheet(isPresented: $showMeasureSheet) {
            MeasureSheetView(isPresented: $showMeasureSheet, measuredDistance: $measuredDistance, isMeasuredFirstPoint: $isMeasuredFirstPoint, isReturnToInit: $isReturnToInit) // Your custom bottom sheet view
                .presentationDetents([
                    .height(130),   // 100 points
                ])
                .presentationCornerRadius(0)
                .presentationBackgroundInteraction(.enabled(upThrough: .height(130)))
        }
        .sheet(isPresented: $showPipelineSheet) {
            PipelineSheetView(
                isPresented: $showPipelineSheet,
                isDrawFirstPoint: $isPipelineDrawFirstPoint,
                isReturnOneStep: $isPipelineReturnOneStep,
                exportedImage: $pipelineExportedImage,
                isExportImage: $isExportImage,
                isExportCAD: $isExportCAD,
                exportedCADURL: $CAD_url
            )
            .presentationDetents(Set(determineSheetHeight()))
            .presentationCornerRadius(0)
            .presentationBackgroundInteraction(.enabled(upThrough: determineSheetHeight().first!))
        }
        
    }
    
    private func determineSheetHeight() -> [PresentationDetent] {
        if pipelineExportedImage != nil {
            return [.large] // Adjust the height as needed
        } else {
            return [.height(130)] // Default height
        }
    }
    
    
    private func ToolBarView() -> some View{
        VStack{
            Spacer()
            HStack(){
                Spacer()
                pointMeasureButtonView()
                Spacer()
                measureButtonView()
                Spacer()
                pipelineButtonView()
                Spacer()
            }
            .padding(.bottom,20)
        }
    }
    
    private func pointMeasureButtonView() -> some View {
        VStack {
            Button(action: {
                showPointMeasureSheet = false;
                showPointMeasureSheet.toggle()
            }) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.title)
                    .frame(width: 50, height: 50)
                    .background(Circle().fill(Color.white.opacity(0.4)))
                    .foregroundColor(.white)
            }
            Text(NSLocalizedString("Point", comment: "Point"))
                .foregroundColor(.white)
                .font(.footnote)
        }
        .padding(.bottom, 10)
    }
    
    private func measureButtonView() -> some View {
        VStack {
            Button(action: {
                showPipelineSheet = false;
                showMeasureSheet.toggle()
            }) {
                Image(systemName: "ruler")
                    .font(.title)
                    .frame(width: 50, height: 50)
                    .background(Circle().fill(Color.white.opacity(0.4)))
                    .foregroundColor(.white)
            }
            Text(NSLocalizedString("Measure", comment: "measure"))
                .foregroundColor(.white)
                .font(.footnote)
        }
        .padding(.bottom, 10)
    }
    private func pipelineButtonView() -> some View {
        VStack {
            Button(action: {
                showPipelineSheet.toggle()
                showMeasureSheet = false
            }) {
                Image(systemName: "skew")
                    .font(.title)
                    .frame(width: 50, height: 50)
                    .background(Circle().fill(Color.white.opacity(0.4)))
                    .foregroundColor(.white)
            }
            Text(NSLocalizedString("Pipeline", comment: "measure"))
                .foregroundColor(.white)
                .font(.footnote)
        }
        .padding(.bottom, 10)
    }
}

