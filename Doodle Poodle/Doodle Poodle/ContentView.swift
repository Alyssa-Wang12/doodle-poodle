//
//  DrawingView.swift
//  Doodle Poodle
//
//  Created by Wang, Alyssa on 4/29/24.
//


import SwiftUI
import Foundation
import AVFAudio

struct ContentView: View {
    
    @State var audioPlayer: AVAudioPlayer!
    
    @State var timeRemaining = 10
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    
    @State private var index = 0
    @State private var words = ["carrot", "cat", "cake", "cupcake", "tree", "apple", "fish", "sandwich", "flower", "house", "computer", "galaxy", "donut", "mountains", "horse", "volcano", "dinosuar", "garden", "thunderstorm", "flag", "face", "eye"]

    @State private var poodleReaction = ["*woof* That belongs in the museum next to the Mona Lisa!", "*bark* If I had to choose between a dog toy and your art... I would choose my dog toy :(", "If I had to choose between a dog toy and your art... I would choose your art! :D", "*wags tail* I love it!", "Its... okay", "WOW! I would frame that and put it up in my dog house!"]
    @State private var poodleSpeak = "The doodle poodle says..."
    @State private var poodleButtonStr = "REVEAL HIS JUDGEMENT"
    @State private var poodleClick = 0
    @State private var endStr = ""
    
    
    @State private var homeScreenOn = true
    @State private var freeDrawOn = false
    @State private var gameOn = false
    @State private var chooseTimeOn = false
    
    @State private var nextButtonOn = false
    @State private var poodleOn = false
    
    @State private var lines = [Line]()
    @State private var deletedLines = [Line]()
    
    @State private var selectedColor: Color = .black
    @State private var selectedLineWidth: CGFloat = 3
    
    let engine = DrawingEngine()
    @State private var showConfirmation: Bool = false
    
    
    var body: some View {
        
        HStack {
            if !gameOn && !freeDrawOn && homeScreenOn {
                
                Button("Free Draw") {
                    
                  playSound(soundNumber: 0)
                    
                    freeDrawOn = true
                    homeScreenOn = false
                    lines = [Line]()
                    deletedLines = [Line]()
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)
                .padding()
                .font(Font.custom("Avenir Next", size: 20))
                
                
                
                Button("Play a game!") {
                    playSound(soundNumber: 0)
                
                    gameOn = true
                    homeScreenOn = false
                    index = Int.random(in:0...words.count - 1)
                    lines = [Line]()
                    deletedLines = [Line]()
                    timeRemaining = 10
                    
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)
                .padding()
                .font(Font.custom("Avenir Next", size: 20))
               
            }
            
            if freeDrawOn {
                VStack {
                    
                    HStack {
                        
                        Button {
                            playSound(soundNumber: 1)
                         reset()
                        } label: {
                            Image(systemName: "house.fill")
                        }
                        
                        ColorPicker("line color", selection: $selectedColor)
                            .labelsHidden()
                        Slider(value: $selectedLineWidth, in: 1...20) {
                            Text("linewidth")
                        }.frame(maxWidth: 100)
                        Text(String(format: "%.0f", selectedLineWidth))
                        
                        Spacer()
                        
                        Button {
                            let last = lines.removeLast()
                            deletedLines.append(last)
                            
                            playSound(soundNumber: 2)
                        }  label: {
                            Image(systemName: "arrow.uturn.backward.circle")
                                .imageScale(.large)
                        }.disabled(lines.count == 0)
                        
                        Button {
                            let last = deletedLines.removeLast()
                            lines.append(last)
                            
                            playSound(soundNumber: 2)
                        } label: {
                            Image(systemName: "arrow.uturn.forward.circle")
                                .imageScale(.large)
                        }.disabled(deletedLines.count == 0 )
                        
                        Button(action: {
                            showConfirmation = true
                            playSound(soundNumber: 5)
                        }) {
                            Text("Delete")
                        }.foregroundColor(.red)
                            .confirmationDialog(Text("Are you sure you want to delete everything?"), isPresented: $showConfirmation) {
                                
                                Button("Delete", role: .destructive) {
                                    lines = [Line]()
                                    deletedLines = [Line]()
                                    playSound(soundNumber: 3)
                                }
                            }
                        
                    }.padding()
                    
                    
                    ZStack {
                        Color.white
                        
                        ForEach(lines){ line in
                            DrawingShape(points: line.points)
                                .stroke(line.color, style: StrokeStyle(lineWidth: line.lineWidth, lineCap: .round, lineJoin: .round))
                        }
                    }
                    
                    
                    
                    //        Canvas { context, size in
                    //
                    //            for line in lines {
                    //
                    //                let path = engine.createPath(for: line.points)
                    //
                    //                context.stroke(path, with: .color(line.color), style: StrokeStyle(lineWidth: line.lineWidth, lineCap: .round, lineJoin: .round))
                    //
                    //            }
                    //        }
                    .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged({ value in
                        let newPoint = value.location
                        if value.translation.width + value.translation.height == 0 {
                            
                            lines.append(Line(points: [newPoint], color: selectedColor, lineWidth: selectedLineWidth))
                        } else {
                            let index = lines.count - 1
                            lines[index].points.append(newPoint)
                        }
                        
                    }).onEnded({ value in
                        if let last = lines.last?.points, last.isEmpty {
                            lines.removeLast()
                        }
                    })
                             
                    )
                    
                    
                }
            } else if gameOn {
                
                if !chooseTimeOn {
                    VStack {
                        Button("10 seconds: EXTREME") {
                            playSound(soundNumber: 2)
                            timeRemaining = 10
                            chooseTimeOn = true
                        }
                        .tint(.red)
                        .padding()
                        
                        Button("20 seconds: HARD") {
                            playSound(soundNumber: 2)
                            timeRemaining = 20
                            chooseTimeOn = true
                        }
                        .tint(.orange)
                        .padding()
                        
                        Button("50 seconds: NORMAL") {
                            playSound(soundNumber: 2)
                            timeRemaining = 50
                            chooseTimeOn = true
                        }
                        .tint(.yellow)
                        .padding()
                        
                        Button("90 seconds: EASY") {  playSound(soundNumber: 2)
                            timeRemaining = 90
                            chooseTimeOn = true
                        }
                        .tint(.green)
                        .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .font(Font.custom("Avenir Next", size: 20))
                    
                }  else if chooseTimeOn {
                    
                    VStack {
                        
                        
                        
                        HStack {
                            
                            
                            Button {
                                playSound(soundNumber: 1)
                                reset()
                            } label: {
                                Image(systemName: "house.fill")
                            }
                            
                            ColorPicker("line color", selection: $selectedColor)
                                .labelsHidden()
                            Slider(value: $selectedLineWidth, in: 1...20) {
                                Text("linewidth")
                            }.frame(maxWidth: 100)
                            Text(String(format: "%.0f", selectedLineWidth))
                            
                            Spacer()
                            
                            Button {
                                let last = lines.removeLast()
                                deletedLines.append(last)
                                
                                playSound(soundNumber: 2)
                            } label: {
                                Image(systemName: "arrow.uturn.backward.circle")
                                    .imageScale(.large)
                            }.disabled(lines.count == 0 || endStr == "Time's up!")
                            
                            Button {
                                let last = deletedLines.removeLast()
                                lines.append(last)
                                
                                playSound(soundNumber: 2)
                            } label: {
                                Image(systemName: "arrow.uturn.forward.circle")
                                    .imageScale(.large)
                            }.disabled(deletedLines.count == 0 || endStr == "Time's up!")
                            
                            
                            
                        }.padding()
                        
                        
                        
                        if nextButtonOn {
                            Button("Next") {
                                playSound(soundNumber: 2)
                                gameOn = false
                                poodleOn = true
                            }
                            
                            .buttonStyle(.borderedProminent)
                            .frame(maxHeight: 25)
                            .font(Font.custom("Avenir Next", size: 20))
                            
                        }
                        
                        
                        ZStack {
                            Color.white
                            
                            ForEach(lines){ line in
                                DrawingShape(points: line.points)
                                    .stroke(line.color, style: StrokeStyle(lineWidth: line.lineWidth, lineCap: .round, lineJoin: .round))
                            }
                        }
                        
                        //.frame(maxHeight: 500)
                        
                        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged({ value in
                            let newPoint = value.location
                            if value.translation.width + value.translation.height == 0 {
                                
                                lines.append(Line(points: [newPoint], color: selectedColor, lineWidth: selectedLineWidth))
                            } else {
                                let index = lines.count - 1
                                lines[index].points.append(newPoint)
                            
                            }
                            
                        }).onEnded({ value in
                            if let last = lines.last?.points, last.isEmpty {
                                lines.removeLast()
                            } else if let last = lines.last?.points, endStr == "Time's up!" {
                                lines.removeLast()
                            }
                        })
                                 
                        )
                        
                   
                        Text("Draw a: \(words[index])")
                            .font(Font.custom("Avenir Next", size: 35))
                        
                        
                        Text("\(timeRemaining)")
                            .onReceive(timer) { _ in
                                
                                if timeRemaining > 0 {
                                    timeRemaining -= 1
                                } else {
                                    endStr = "Time's up!"
                                    nextButtonOn = true
                                }
                            }
                        
                        
                            .font(Font.custom("Avenir Next", size: 30))
                        
                        
                        Text(endStr)
                            .foregroundColor(.red)
                            .font(Font.custom("Avenir Next", size: 20))
                            .frame(height: 20)
                        
                        
                        
                        
                        
                        
                        
                    }
                }
            } else if poodleOn {
                
                VStack {
                    
                   
                    Image("speechBubble")
                        .resizable()
                        .scaledToFit()
                        .padding(.bottom, -30.0)
                        .padding()
                        .overlay(
                            
                            Text(poodleSpeak)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .padding(30.0)
                            .padding(.bottom, -10)
                            .font(Font.custom("Avenir Next", size: 20))
                            .frame(height: 170)
                            .animation(.easeIn(duration: 0.2))
                          
                        
                        )
                  
                       
                    
                    Image("poodle")
                        .resizable()
                        .scaledToFit()
                        .padding(.top, -20.0)
                       
                
                    
                    Button(poodleButtonStr) {
                        playSound(soundNumber: 4)
                        poodleSpeak = poodleReaction[Int.random(in:0...poodleReaction.count - 1)]
                        if (index == 1) {
                            poodleSpeak = "A cat! Can I chase it?"
                        } else if (index == 2 || index == 12) {
                            poodleSpeak = "That looks delicious... yum!"
                        }
                        
                        poodleButtonStr = "Play Again?"
                        poodleClick += 1
                        
                        if poodleClick == 2 {
                            playSound(soundNumber: 6)
                            reset()
                        }
                        
                    }
                    .buttonStyle(.borderedProminent)
                    .font(Font.custom("Avenir Next", size: 20))
                    .padding()
                    .frame(height: 100)
                    
                } .padding(25.0)
                
            }
            
            
            
            
        }
    }
    
  
    func reset() {
        freeDrawOn = false
        chooseTimeOn = false
        gameOn = false
        poodleSpeak = "The doodle poodle says..."
        poodleButtonStr = "REVEAL HIS JUDGEMENT"
        poodleClick = 0
        nextButtonOn = false
        poodleOn = false
        homeScreenOn = true
        endStr = ""
    }
    func playSound(soundNumber: Int){
        var soundName = "sound\(soundNumber)"
        
        
        guard let soundFile = NSDataAsset(name: soundName) else {
            print("😡 Could not read file named \(soundName)")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(data: soundFile.data)
            audioPlayer.play()
        }catch{
            print("😡 ERROR:\(error.localizedDescription) creating audioPlayer.")
        }
    }
   
   
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
