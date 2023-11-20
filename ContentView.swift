import SwiftUI



struct ContentView: View {

    @State private var containerViews: [UUID: ContainerView] = [:]

    @State private var selectedContainerId: UUID?





    var body: some View {

        ZStack {

            ForEach(Array(containerViews.keys), id: \.self) { key in

                containerViews[key]

                    .padding()

                    .offset(x: 0, y: CGFloat(Array(containerViews.keys).firstIndex(of: key) ?? 0) * 20)

                    .onTapGesture {

                        self.selectedContainerId = key

                    }

                    .opacity(self.selectedContainerId == key ? 1.0 : 0.5)

            }

            Button(action: {

                let newContainerView = ContainerView(selectedId: $selectedContainerId)

                containerViews[newContainerView.id] = newContainerView

            }) {

                Image(systemName: "plus")

                    .font(.title)

                    .frame(width: 60, height: 60)

                    .background(Color.blue)

                    .foregroundColor(.white)

                    .clipShape(Circle())

            }

            .padding()

            .offset(x: UIScreen.main.bounds.width / 2 - 60, y: UIScreen.main.bounds.height / 2 - 80)



            Button(action: {

                if let selectedId = selectedContainerId {

                    containerViews.removeValue(forKey: selectedId)

                    selectedContainerId = nil

                }

            }) {

                Image(systemName: "trash")

                    .font(.title)

                    .frame(width: 60, height: 60)

                    .background(Color.red)

                    .foregroundColor(.white)

                    .clipShape(Circle())

            }

            .padding()

            .offset(x: -UIScreen.main.bounds.width / 2 + 60, y: UIScreen.main.bounds.height / 2 - 80)

        }

        .edgesIgnoringSafeArea(.all)

    }

}



struct ContainerView: View, Identifiable {

    let id = UUID()

    @Binding var selectedId: UUID?



    @State private var rectangleSize = CGSize(width: 320, height: 160)

    @State private var horizontalLines: [CGFloat] = []

    @State private var verticalLines: [CGFloat] = []

    @State private var selectedLineIndex: Int?

    @State private var dragOffset: CGSize = .zero

    @State private var containerDragOffset: CGSize = .zero



    @State private var tappedPointX: CGFloat = 0 //

    @State private var tappedPointY: CGFloat = 0 //

    @State private var tapLocation: CGPoint = .zero





    var body: some View {

        VStack {

            GeometryReader { geometry in

                ZStack {

                    Rectangle()

                        .fill(Color.clear)

                        .frame(width: rectangleSize.width, height: rectangleSize.height)

                        .border(Color.black, width: 1)

                        .contentShape(Rectangle().stroke())



                    ForEach(horizontalLines.indices, id: \.self) { index in
                                            Path { path in
                                                path.move(to: CGPoint(x: 0, y: self.horizontalLines[index] * geometry.size.height))
                                                path.addLine(to: CGPoint(x: geometry.size.width, y: self.horizontalLines[index] * geometry.size.height))
                                            }
                                            .stroke(Color.black, lineWidth: 2)
                                            .gesture(
                                                DragGesture()
                                                    .onChanged { value in
                                                        self.horizontalLines[index] = value.location.y / geometry.size.height
                                                    }
                                            )
                                        }

                                        ForEach(verticalLines.indices, id: \.self) { index in
                                            Path { path in
                                                path.move(to: CGPoint(x: self.verticalLines[index] * geometry.size.width, y: 0))
                                                path.addLine(to: CGPoint(x: self.verticalLines[index] * geometry.size.width, y: geometry.size.height))
                                            }
                                            .stroke(Color.black, lineWidth: 2)
                                            .gesture(
                                                DragGesture()
                                                    .onChanged { value in
                                                        self.verticalLines[index] = value.location.x / geometry.size.width
                                                    }
                                            )
                                        }
                                    }
                                }


                    Circle()

                        .fill(Color.blue)

                        .frame(width: 20, height: 20)

                        .position(x: rectangleSize.width, y: rectangleSize.height)

                        .gesture(

                            DragGesture(minimumDistance: 0)

                                .onChanged { value in

                                    let newWidth = max(value.location.x, 15)

                                    let newHeight = max(value.location.y, 15)

                                    adjustContainerSize(width: newWidth, height: newHeight)

                                }

                        )



                    Circle()

                        .fill(Color.blue)

                        .frame(width: 20, height: 20)

                        .position(x: 0, y: 0)

                        .gesture(

                            DragGesture()

                                .onChanged { value in

                                    self.containerDragOffset = CGSize(width: value.translation.width + self.containerDragOffset.width, height: value.translation.height + self.containerDragOffset.height)

                                    self.selectedId = self.id //

                                }

                                .onEnded { value in

                                    self.containerDragOffset = CGSize(width: value.translation.width + self.containerDragOffset.width, height: value.translation.height + self.containerDragOffset.height)

                                }

                        )

                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: 4, height: geometry.size.height)
                                        .background(Color.blue)
                                        .position(x: 4 / 2, y: geometry.size.height / 2)
                                        .gesture(
                                            SpatialTapGesture()
                                                .onEnded { value in
                                                    tappedPointY = value.location.y / geometry.size.height
                                                    addHorizontalLine()
                                                }
                                        )
                                        .zIndex(1)

                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: geometry.size.width, height: 4)
                                        .background(Color.blue)
                                        .position(x: geometry.size.width / 2, y: 4 / 2)
                                        .gesture(
                                            SpatialTapGesture()
                                                .onEnded { value in
                                                    tappedPointX = value.location.x / geometry.size.width
                                                    addVerticalLine()
                                                }
                                        )
                                        .zIndex(1)
                }

                .offset(x: dragOffset.width, y: dragOffset.height)

                .offset(x: containerDragOffset.width, y: containerDragOffset.height)

            }

            .frame(width: rectangleSize.width, height: rectangleSize.height)



        }

        .padding(.horizontal, 20)

    }



    private func addHorizontalLine() {
            horizontalLines.append(tappedPointY)
        }
        
    private func addVerticalLine() {
        verticalLines.append(tappedPointX)
    }


    private func deleteHorizontalLine(at index: Int) {

        horizontalLines.remove(at: index)

        self.selectedId = self.id //

    }



    private func deleteVerticalLine(at index: Int) {

        verticalLines.remove(at: index)

        self.selectedId = self.id //

    }



    private func dragHorizontalLine(at index: Int, dragValue: DragGesture.Value) {

        let dragY = dragValue.location.y - dragOffset.height

        let minY: CGFloat = 0

        let maxY = rectangleSize.height



        if index > 0 {

            let prevLineY = horizontalLines[index - 1]

            let snapY = prevLineY + 1

            if dragY < snapY {

                horizontalLines[index] = snapY

                return

            }

        }



        if index < horizontalLines.count - 1 {

            let nextLineY = horizontalLines[index + 1]

            let snapY = nextLineY - 1

            if dragY > snapY {

                horizontalLines[index] = snapY

                return

            }

        }



        let adjustedY = max(minY, min(dragY, maxY))

        horizontalLines[index] = adjustedY



        self.selectedId = self.id //

    }



    private func dragVerticalLine(at index: Int, dragValue: DragGesture.Value) {

        let dragX = dragValue.location.x - dragOffset.width

        let minX: CGFloat = 0

        let maxX = rectangleSize.width



        if index > 0 {

            let prevLineX = verticalLines[index - 1]

            let snapX = prevLineX + 1

            if dragX < snapX {

                verticalLines[index] = snapX

                return

            }

        }



        if index < verticalLines.count - 1 {

            let nextLineX = verticalLines[index + 1]

            let snapX = nextLineX - 1

            if dragX > snapX {

                verticalLines[index] = snapX

                return

            }

        }



        let adjustedX = max(minX, min(dragX, maxX))

        verticalLines[index] = adjustedX



        self.selectedId = self.id //

    }



    private func longPressGesture() -> some Gesture {

        LongPressGesture(minimumDuration: 0.5)

    }



    private func adjustContainerSize(width: CGFloat, height: CGFloat) {

        let maxX = verticalLines.last ?? 0

        let maxY = horizontalLines.last ?? 0



        let newWidth = max(width, maxX + 5)

        let newHeight = max(height, maxY + 5)

        rectangleSize = CGSize(width: newWidth, height: newHeight)



        self.selectedId = self.id //



        }

}



struct LineView: View {

    var startPoint: CGPoint

    var endPoint: CGPoint



    var body: some View {

        Path { path in

            path.move(to: startPoint)

            path.addLine(to: endPoint)

        }

        .stroke(Color.black, lineWidth: 1)

    }

}



struct ContentView_Previews: PreviewProvider {

    static var previews: some View {

        ContentView()

    }

}
