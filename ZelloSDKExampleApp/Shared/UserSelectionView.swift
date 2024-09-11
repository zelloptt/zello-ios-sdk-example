import SwiftUI
import ZelloSDK

struct UserSelectionView: View {
  @Binding var isVisible: Bool
  @Binding var selectedUsers: [ZelloUser]
  let allUsers: [ZelloUser]
  let title: String
  let onCreate: () -> Void

  var body: some View {
    VStack {
      Text(title)
        .font(.headline)
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.white))

      if allUsers.isEmpty {
        Text("No users available")
      } else {
        List(allUsers, id: \.id) { user in
          HStack {
            Text(user.displayName)
            Spacer()
            CheckBoxView(
              isChecked: selectedUsers.contains(where: { $0.id == user.id }),
              onTap: {
                if let index = selectedUsers.firstIndex(where: { $0.id == user.id }) {
                  selectedUsers.remove(at: index)
                } else {
                  selectedUsers.append(user)
                }
              }
            )
          }
        }
      }

      HStack {
        Button("Cancel") {
          isVisible = false
        }
        .padding()
        Spacer()
        Button("Continue") {
          onCreate()
          isVisible = false
        }
        .padding()
      }
    }
    .padding()
    .background(Color.white)
    .cornerRadius(10)
    .shadow(radius: 10)
    .overlay(
      RoundedRectangle(cornerRadius: 10)
        .stroke(Color.gray, lineWidth: 2)
    )
    .padding(.horizontal, 20)
    .onAppear {
      selectedUsers.removeAll()
    }
  }
}


struct CheckBoxView: View {
  let isChecked: Bool
  let onTap: () -> Void

  var body: some View {
    Button(action: {
      onTap()
    }) {
      Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
        .foregroundColor(isChecked ? .blue : .gray)
        .font(.system(size: 24))
    }
    .buttonStyle(PlainButtonStyle())
  }
}
