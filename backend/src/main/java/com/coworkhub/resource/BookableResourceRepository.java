// Owner: Erin
// What: Reads and writes rooms and desks. findAll returns both kinds, each as its real subclass.
// Checklist: GET /api/resources can filter by type, minimum capacity, location, and maximum price.
// Depends on: BookableResource (done).
//
// The brief says to add derived query methods only when the application needs them.
// TODO(Erin): Use findAll() and the loop in ResourceService.findResources with ResourceFilter.matches.
//             All four optional filters combine with AND. No extra derived queries are needed.
//             This repository handles both subtypes; do not add separate room and desk repositories.

package com.coworkhub.resource;

import org.springframework.data.jpa.repository.JpaRepository;

public interface BookableResourceRepository extends JpaRepository<BookableResource, Long> {
}
