// Owner: Erin
// What: Reads and writes rooms and desks. findAll returns both kinds, each as its real subclass.
// Checklist: GET /api/resources can filter by type, minimum capacity, location, and maximum price.
// Depends on: BookableResource (done).
//
// The brief says to add derived query methods only when the application needs them.
// TODO(Erin): Choose how filtering works and add only what you use. Either
//             (a) findAll() and filter the list in ResourceService.findResources, or
//             (b) derived queries such as
//                 List<BookableResource> findByCapacityGreaterThanEqual(Integer minCapacity);
//                 List<BookableResource> findByLocationContainingIgnoreCase(String location);
//                 List<BookableResource> findByHourlyRateLessThanEqual(BigDecimal maxHourlyRate);
//             Option (a) is simpler because all four filters are optional and combine with AND.

package com.coworkhub.resource;

import org.springframework.data.jpa.repository.JpaRepository;

public interface BookableResourceRepository extends JpaRepository<BookableResource, Long> {
}
