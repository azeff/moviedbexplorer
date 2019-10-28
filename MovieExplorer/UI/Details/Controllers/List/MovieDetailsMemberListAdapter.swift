//
//  MovieDetailsMemberListAdapter.swift
//  MovieExplorer
//
//  Created by Evgeny Kazakov on 10/19/19.
//  Copyright © 2019 Evgeny Kazakov. All rights reserved.
//

import UIKit

class MovieDetailsMemberListAdapter {
  
  func list(_ members: [MoviePersonellMemberViewModel]) -> List {
    var section = ListSection(members.map(memberListItem))
    section.minimumInteritemSpacing = 8
    section.minimumLineSpacing = 8
    section.inset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

    return List(sections: [section])
  }
  
  private func memberListItem(_ member: MoviePersonellMemberViewModel) -> ListItem {
    MovieDetailsMemberListItem(member: member)
  }
}
