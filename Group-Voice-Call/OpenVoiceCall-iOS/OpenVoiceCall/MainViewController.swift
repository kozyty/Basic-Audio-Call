//
//  MainViewController.swift
//  OpenVoiceCall
//
//  Created by GongYuhua on 16/8/17.
//  Copyright © 2016年 Agora. All rights reserved.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController {

    @IBOutlet weak var roomNameTextField: UITextField!
    @IBOutlet weak var playerButton: UIButton!

    var audioPlayer: AVAudioPlayer!

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueId = segue.identifier , segueId == "mainToRoom",
            let roomName = sender as? String else {
            return
        }

        let roomVC = segue.destination as! RoomViewController
        roomVC.roomName = roomName
        roomVC.delegate = self
    }

    @IBAction func doRoomNameTextFieldEditing(_ sender: UITextField) {
        if let text = sender.text , !text.isEmpty {
            let legalString = MediaCharacter.updateToLegalMediaString(from: text)
            sender.text = legalString
        }
    }

    @IBAction func doJoinPressed(_ sender: UIButton) {
        enter(roomName: roomNameTextField.text)
    }

    @IBAction func playAudio(_ sender: Any) {
        guard let audioPlayer = self.audioPlayer else {
            playRecord()
            return
        }

        if audioPlayer.isPlaying {
            stopPlayer()
        } else {
            playRecord()
        }
    }
}

extension MainViewController: AVAudioPlayerDelegate {
    func playRecord() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let filePath = documentsPath + "/voice.wav"

        guard FileManager.default.fileExists(atPath: filePath) else {
            print("録音ファイルが見つかりません")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: filePath))
            audioPlayer.delegate = self
            audioPlayer.play()
        } catch {
            print("録音ファイルを再生できません")
        }
    }

    func stopPlayer() {
        guard let audioPlayer = self.audioPlayer else { return }
        if audioPlayer.isPlaying {
            audioPlayer.stop()
        }
    }
}

private extension MainViewController {
    func enter(roomName: String?) {
        guard let roomName = roomName , !roomName.isEmpty else {
            return
        }
        performSegue(withIdentifier: "mainToRoom", sender: roomName)
        stopPlayer()
    }
}

extension MainViewController: RoomVCDelegate {
    func roomVCNeedClose(_ roomVC: RoomViewController) {
        dismiss(animated: true, completion: nil)
    }
}

extension MainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        enter(roomName: textField.text)
        return true
    }
}
